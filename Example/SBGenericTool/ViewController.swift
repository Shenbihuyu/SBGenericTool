//
//  ViewController.swift
//  SBGenericTool
//
//  Created by waing on 07/20/2020.
//  Copyright (c) 2020 waing. All rights reserved.
//

import UIKit
import SBGenericTool


enum CellType : Int, IndexPathGeneticable, CaseIterable  {
    
    case update = 0
    case shareApp
    case recommendApp
    case recommendAppNet
    case feedback
    case comments
    
    case suggest = 100
    case privacy
    
    case dev = 200
    
    case version = 300
}

class ViewController: UITableViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var serverVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadServerVersion()
        
        MemberToolBox.checkAppStoreVersion { (version) in
            if let version = version {
                self.versionLabel.text = "商店版本号\(version), 本地版本号\(MemberToolBox.appVersion())"
            }else {
                self.versionLabel.text = "商店没有该APP"
            }
        }
    }
    
    func loadServerVersion() {
        serverVersionLabel.text = (SBVersion.anquan ? "安全" : "不安全") +
            " , " +
            (SBVersion.guanggao ? "开广告" : "关广告")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch CellType(indexPath: indexPath) {
        case .update:
            MemberToolBox.updataAtAppStore()
        case .shareApp:
            MemberToolBox.shareApp(onViewController: self)
        case .recommendApp:
            MemberToolBox.shared.recommendAtAppStore(appid: "1504377117", on: self, completionHandler: { (success) in
                
            })
        case .comments:
            MemberToolBox.commentsAtAppStore()
        case .suggest:
            MemberToolBox.presentSuggestView(onViewController: self, suggestUrl: 问卷星意见link)
        case .privacy:
            MemberToolBox.presentWebPage(onViewController: self,
                                         url: 隐私政策link,
                                         title: "隐私政策")
        case .dev:
            devAction()
        case .version:
            VersionMenager.checkVersion { (version, error) in
                self.loadServerVersion()
            }
        default: break
        }
    }
    
    func devAction() {
        let vc = DevSettingViewController()
        vc.addOption(VipDownloadCount())
        vc.addOption(UserInfoCopy())
        vc.ipaResetCallBack = {

        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

struct UserInfoCopy: DevOptionCellAble, DevOptionCopyable {
    var copyString: String {
        return "广告ID xxxxxxxx"
    }
    var detail: String? { return nil }
    var title: String {
        return "广告ID"
    }
}

struct VipDownloadCount: DevOptionCountable, DevOptionCellAble {
    var detail: String? { return nil }
    var title: String {
        return "vip下载次数"
    }
}

let 问卷星意见link = "https://www.wjx.cn/jq/84580778.aspx"
let 隐私政策link   = "https://www.shenbihuyu.com/app_privacy.html"
