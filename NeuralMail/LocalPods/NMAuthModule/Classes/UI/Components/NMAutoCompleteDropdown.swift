import UIKit
import SnapKit
import NMKit

class NMAutoCompleteDropdown: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var onSelect: ((String) -> Void)?
    
    private var dataSource: [String] = []
    private let cellIdentifier = "AutoCompleteCell"
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = NMColor.backgroundCard
        tv.separatorStyle = .singleLine
        tv.separatorColor = NMColor.borderInput.withAlphaComponent(0.3)
        tv.layer.cornerRadius = 12
        tv.layer.masksToBounds = true
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = 44
        // 注册 Cell
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 添加阴影，营造悬浮感
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 默认隐藏
        self.isHidden = true
    }
    
    // MARK: - Public Methods
    
    func updateData(_ data: [String]) {
        self.dataSource = data
        self.tableView.reloadData()
        
        // 根据数据量动态调整高度 (最大显示 4 行，约 176pt)
        let count = CGFloat(min(data.count, 4))
        let height = count * 44
        
        self.isHidden = data.isEmpty
        
        // 更新自身高度约束
        self.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = NMColor.backgroundCard
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 14) // NMFont.body
        cell.textLabel?.textColor = NMColor.textPrimary
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedText = dataSource[indexPath.row]
        onSelect?(selectedText)
        self.isHidden = true
    }
}