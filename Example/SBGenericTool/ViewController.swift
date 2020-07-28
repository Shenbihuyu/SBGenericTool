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
    
    case shareApp = 0
    case recommendApp
    case comments
    
    case suggest = 100
    case privacy
    
    case dev = 200
}

class ViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch CellType(indexPath: indexPath) {
        case .shareApp:
            MemberToolBox.shareApp(onViewController: self)
        case .recommendApp:
            MemberToolBox.recommendAtAppStore(recommendAppid: "1504377117")
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
