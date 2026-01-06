//
//  NMMailHomeViewController.swift
//  NMFeatureHome
//
//  Created by 小大 on 2025/12/26.
//

import UIKit
import Combine
import NMKit
import NMModular
import SideMenu

class NMMailHomeViewController: NMViewController {
    
    // MARK: - Properties
    
    @NMLogger("NMFeatureHome") private var logger
    
    // ✅ ViewModel 直接初始化 (因为是页面级 VM，且内部使用了 @NMInjected)
    private let viewModel = NMMailHomeViewModel()
    
    private var sideMenuNav: SideMenuNavigationController?
    
    // ✅ Combine 订阅存储
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        // 注册 Cell
        table.register(NMMailListCell.self, forCellReuseIdentifier: NMMailListCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 88
        table.separatorStyle = .singleLine
        table.tableFooterView = UIView()
        
        // 增加底部 Loading View (用于上拉加载)
        let footerView = UIActivityIndicatorView(style: .medium)
        footerView.frame = CGRect(x: 0, y: 0, width: table.bounds.width, height: 44)
        table.tableFooterView = footerView
        return table
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var emptyView: UILabel = {
        let label = UILabel()
        label.text = "暂无邮件"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupSideMenu()
        // 首次进入自动刷新
        viewModel.refresh()
    }
    
    // MARK: - UI Setup
    
    override func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.folderDisplayName
        
        // Navigation Items
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchTapped)
        )
        
        // TableView Layout
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Empty View
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Binding (Combine)
    
    private func bindViewModel() {
        
        viewModel.$folderDisplayName
            .receive(on: RunLoop.main)
            .sink { [weak self] folderDisplayName in
                self?.title = folderDisplayName
            }
            .store(in: &cancellables)
        
        // 1. 绑定列表数据源 ($items)
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
            
        // 2. 绑定主状态 ($state)
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.updateViewState(state)
            }
            .store(in: &cancellables)
            
        // 3. 绑定加载更多状态 ($isLoadingMore)
        viewModel.$isLoadingMore
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                // 控制底部菊花的显隐
                if let loader = self.tableView.tableFooterView as? UIActivityIndicatorView {
                    if isLoading {
                        loader.startAnimating()
                        loader.isHidden = false
                    } else {
                        loader.stopAnimating()
                        loader.isHidden = true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateViewState(_ state: NMMailHomeViewModel.ViewState) {
        switch state {
        case .loading:
            // 只有不是下拉刷新触发的 loading 才显示全屏 HUD
            if !refreshControl.isRefreshing {
                // NMHUD.showLoading() // 可选
            }
            emptyView.isHidden = true
            
        case .idle:
            refreshControl.endRefreshing()
            emptyView.isHidden = true
            // NMHUD.dismiss()
            
        case .empty:
            refreshControl.endRefreshing()
            emptyView.isHidden = false
            
        case .error(let msg):
            refreshControl.endRefreshing()
            // NMHUD.showToast(type: .error, body: msg)
            logger.error(msg)
        }
    }
    
    private func setupSideMenu() {
        
        let currentPath = viewModel.currentFolder?.path ?? "INBOX"
        let sidebarVM = NMMailSidebarViewModel(selectedPath: currentPath)
        
        let sidebarVC = NMMailSidebarViewController(viewModel: sidebarVM)
        
        sidebarVC.didSelectFolder = { [weak self] folder in
            
            self?.dismiss(animated: true, completion:nil)
            
            if folder.path != self?.viewModel.currentFolder?.path {
                self?.viewModel.switchFolder(folder)
            }
        }
        
        let menu = SideMenuNavigationController(rootViewController: sidebarVC)
        
        menu.leftSide = true // 从左侧弹出
        menu.presentationStyle = .viewSlideOutMenuPartialIn // 风格：覆盖在上面
        menu.menuWidth = view.frame.width * 0.8 // 宽度占 80%
        menu.blurEffectStyle = .systemThinMaterial // 毛玻璃背景
        
        self.sideMenuNav = menu
        
        SideMenuManager.default.leftMenuNavigationController = menu
        
        // 将手势添加到 self.view 或者 self.navigationController.view
        // 建议加到 navigationController.view 以便覆盖 NavigationBar
        if let navView = self.navigationController?.view {
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: navView)
        } else {
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        }
    }
    
    private func updateSidebarSelection() {
        guard let nav = sideMenuNav,
              let sidebarVC = nav.viewControllers.first as? NMMailSidebarViewController else { return }
        
        // 你可以在 SidebarVC 里加一个 updateSelection(path:) 方法
        // sidebarVC.updateSelection(path: viewModel.currentFolder?.path)
    }
    
    // MARK: - Actions
    
    @objc private func handleRefresh() {
        viewModel.refresh()
    }
    
    @objc private func menuTapped() {
        logger.info("Menu Tapped")
        
        guard let menu = sideMenuNav else { return }
        
        // 可选：每次打开前更新一下选中状态 (因为 Sidebar 实例是常驻内存的)
        updateSidebarSelection()
        
        present(menu, animated: true)
    }
    
    @objc private func searchTapped() {
        logger.info("Search Tapped")
        // NMRouter.shared.push("/search")
    }
}

// MARK: - UITableViewDataSource

extension NMMailHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NMMailListCell.reuseIdentifier, for: indexPath) as? NMMailListCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NMMailHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        
        // 路由跳转到详情页
         NMRouter.shared.push(to: "/mail/detail?id=\(item.id)")
    }
    
    // 自动加载更多逻辑
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalCount = viewModel.items.count
        // 当滑动到倒数第 3 个，且不是正在刷新或加载中
        if totalCount > 0, indexPath.row == totalCount - 3 {
            viewModel.loadMore()
        }
    }
}
