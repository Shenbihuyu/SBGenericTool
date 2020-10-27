//
//  DevSettingViewController.swift
//  SBVideoTool
//
//  Created by 王剑鹏 on 2020/6/10.
//  Copyright © 2020 Lete. All rights reserved.
//

import UIKit
import SnapKit

let devOptionKey = "com.devOption."

public enum SBDevOption : String {
    case showAd // 显示广告
    case isIAP  // 走苹果内购
}

extension SBDevOption: DevOptionSwitchable, DevOptionCellAble {
    public var title : String {
        switch self {
        case .showAd: return "是否显示广告"
        case .isIAP : return "是否开启沙盒储值"
        }
    }
    public var detail : String? {
        switch self {
        case .showAd: return "开发模式下，打开开关后会更具当前时间逻辑显示广告，关闭则不显示广告"
        case .isIAP : return "开发模式下，打开开关后会走苹果的沙盒支付逻辑，关闭则使用本地车上数据完成购买"
        }
    }
}

/// 开发设置页面
public class DevSettingViewController: UIViewController {
    fileprivate let cellIdentifier = "devTableCell"
    fileprivate var optionsList : [DevOptionCellAble] = [SBDevOption.showAd, SBDevOption.isIAP]
    
    /// 添加设置选项
    open func addOption(_ option : DevOptionCellAble) {
        optionsList.append(option)
    }
    /// 重置购买按钮响应
    open var ipaResetCallBack : (() -> Void)?
    
    fileprivate lazy var tableView : UITableView = {
        let tableview = UITableView()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.allowsSelection = false
        tableview.register(DevTableCell.self, forCellReuseIdentifier: cellIdentifier )
        tableview.estimatedRowHeight = 80
        return tableview
    }()
    
    fileprivate lazy var resetButton : UIButton = { [weak self] in
        let button = UIButton(type: .custom)
        button.setTitle("重置购买", for: .normal)
        button.setTitleColor(.systemRed , for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        button.addTarget(self, action: #selector(resetVip), for: .touchUpInside)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "开发设置"
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        tableView.tableFooterView = {
            let view = UIView()
            view.addSubview(resetButton)
            view.frame = CGRect(x: 0, y: 0, width: 600, height: 70)
            resetButton.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            return view
        }()
        
    }
    
    @objc func resetVip(sender: UIButton) {
        if ipaResetCallBack == nil {
            let alert = UIAlertController(title: "未配置响应", message: nil, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (action) in
            }))
            present(alert, animated: true, completion: nil)
        }else{
            ipaResetCallBack?()
        }
    }
}

extension DevSettingViewController: UITableViewDelegate, UITableViewDataSource, DevTableCellDelegate {
    func showAlert(withString str: String) {
        let alert = UIAlertController(title: str, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DevTableCell
        cell.model = optionsList[indexPath.row]
        cell.delegate = self
        return cell
    }
}

protocol DevTableCellDelegate : class {
    func showAlert(withString str: String)
}

class DevTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "title"
        return label
    }()
    fileprivate lazy var infoLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "info"
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    fileprivate lazy var switchView : UISwitch = { [weak self] in
        let view = UISwitch()
        view.addTarget(self, action: #selector(switchChange), for: .valueChanged)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var resetButton: UIButton = { [weak self] in
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        btn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btn.isHidden = true
        return btn
    }()
    
    fileprivate func initSubView()  {
        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 8
        labelStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [labelStackView, switchView, resetButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(15)
        }
    }
    
    override func prepareForReuse() {
        switchView.isHidden = true
        resetButton.isHidden = true
        infoLabel.isHidden = true
    }
    
    weak var delegate : DevTableCellDelegate?
    
    var model : DevOptionCellAble? {
        didSet {
            guard let _model = model else { return }
            // cell text
            titleLabel.text = _model.title
            if let _detail = _model.detail {
                infoLabel.text = _detail
                infoLabel.isHidden = false
            }
            // 操作
            if let switchModel = model as? DevOptionSwitchable {
                switchView.isHidden = false
                switchView.isOn = switchModel.isOn
            }else if let _ = model as? DevOptionCopyable {
                resetButton.isHidden = false
                resetButton.setTitle("复制", for: .normal)
            }else if let countModel = model as? DevOptionCountable {
                resetButton.isHidden = false
                resetButton.setTitle(String(format: "重置 (%d)", countModel.count), for: .normal)
            }else if model is UserDefaultsable { //只有重置功能 必须放在最后
                resetButton.isHidden = false
                resetButton.setTitle(String(format: "重置"), for: .normal)
            }
        }
    }
    
    
    /// 开关改变
    /// - Parameter sender: sender
    @objc func switchChange(sender:UISwitch){
        guard let _model = model as? DevOptionSwitchable else { return }
        _model.setSwitch(isOn: sender.isOn)
    }
    
    /// 重置参数
    /// - Parameter sender: sender
    @objc func resetAction(_ sender :UIButton){
        if let countModel = model as? DevOptionCountable {
            countModel.setCount(0)
            resetButton.setTitle(String(format: "重置 (%d)", countModel.count), for: .normal)
            delegate?.showAlert(withString: "重置成功")
        }else if let copyModel = model as? DevOptionCopyable {
            UIPasteboard.general.string = copyModel.copyString
            delegate?.showAlert(withString: "复制成功")
        }else if let _model = model as? UserDefaultsable { //只有重置功能 必须放在最后
            UserDefaults.standard.set(nil, forKey: _model.saveKey)
            UserDefaults.standard.synchronize()
            delegate?.showAlert(withString: "重置成功")
        }
    }
}
