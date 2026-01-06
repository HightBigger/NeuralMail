//
//  NMMailSidebarViewController.swift
//  NMFeatureModule
//
//  Created by 小大 on 2026/1/5.
//

import NMKit
import Combine
import NMModular

class NMMailSidebarViewController: NMViewController {
    
    // MARK: - Properties
    private let viewModel: NMMailSidebarViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Int, SidebarItem>!
    private var collectionView: UICollectionView!
    private var cancellables = Set<AnyCancellable>()
    
    // ✅ 回调：直接传回业务对象
    var didSelectFolder: ((NMMailFolder) -> Void)?
    
    // MARK: - Init
    
    init(viewModel: NMMailSidebarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    
    override func setupUI() {
        // 配置 Sidebar 样式
        var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        config.headerMode = .firstItemInSection // 让 Header 生效
        config.backgroundColor = .systemBackground
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        // 注册 Header Cell
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure()] // 可折叠箭头
        }
        
        // 注册 Item Cell
        let itemRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NMMailFolderItem> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.displayName
            content.image = UIImage(systemName: item.iconName)
            content.imageProperties.tintColor = item.iconColor
            cell.contentConfiguration = content
            
            // 未读数
            if item.unreadCount > 0 {
                let options = UICellAccessory.LabelOptions(font: .preferredFont(forTextStyle: .caption1), adjustsFontForContentSizeCategory: true)
                cell.accessories = [.label(text: "\(item.unreadCount)", options: options)]
            } else {
                cell.accessories = []
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, SidebarItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .header(let title):
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: title)
            case .folder(let folderItem):
                return collectionView.dequeueConfiguredReusableCell(using: itemRegistration, for: indexPath, item: folderItem)
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.$snapshot
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Delegate

extension NMMailSidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 取消高亮 (Sidebar 风格通常不需要手动取消，但为了保险)
        // collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .folder(let folderItem):
            // 🔍 从 VM 找回原始业务对象
            if let folder = viewModel.getFolder(by: folderItem.path) {
                didSelectFolder?(folder)
            }
        default:
            break
        }
    }
}
