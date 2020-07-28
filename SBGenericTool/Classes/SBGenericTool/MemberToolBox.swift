//
//  MemberToolBox.swift
//  SBVideoTool
//
//  Created by 王剑鹏 on 2020/6/10.
//  Copyright © 2020 Lete. All rights reserved.
//

import UIKit

public class MemberToolBox: NSObject {
    public static let shared = MemberToolBox()
}

// MARK: 分享与评论
extension MemberToolBox{
    /// 分享该APP
    /// - Parameter vc: 弹窗ViewController
    public class func shareApp(onViewController vc:UIViewController ) {
        let textToShare = MemberToolBox.appName()
        let imageToShare = UIImage.init(named: "icon")
        let urlToShare = NSURL.init(string: "https://apps.apple.com/cn/app/id" + MemberToolBox.appId())
        let items = [textToShare,imageToShare as Any,urlToShare as Any] as [Any]
        var exclude:[UIActivity.ActivityType] = [UIActivity.ActivityType.message,
                                                 UIActivity.ActivityType.airDrop,
                                                 UIActivity.ActivityType.mail,
                                                 UIActivity.ActivityType.assignToContact,
                                                 UIActivity.ActivityType.postToVimeo,
                                                 UIActivity.ActivityType.print,
                                                 UIActivity.ActivityType.copyToPasteboard,
                                                 UIActivity.ActivityType.saveToCameraRoll,
                                                 UIActivity.ActivityType.postToFlickr,
                                                 UIActivity.ActivityType.openInIBooks,
                                                 UIActivity.ActivityType.addToReadingList]
        if #available(iOS 11.0, *) {
            exclude.append(UIActivity.ActivityType.markupAsPDF)
        }
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
        activityVC.excludedActivityTypes = exclude
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            if success {
                
            }
        }
        vc.present(activityVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    
    /// 去苹果商店评论
    public class func commentsAtAppStore() {
        let appid = MemberToolBox.appId()
        let commentsUrl = "itms-apps://itunes.apple.com/cn/app/id\(appid)?mt=8&action=write-review"
        UIApplication.shared.open(URL(string: commentsUrl)!, completionHandler: { (success) in
            debugPrint("comments opened: \(success)") // Prints true
        })
    }
    
    
    /// 推荐APP - 跳转到应用商店
    /// - Parameter appid: 推荐APP的APPID
    public class func recommendAtAppStore(recommendAppid appid: String?) {
        if let _appid = appid {
            let commentsUrl = "itms-apps://itunes.apple.com/cn/app/id\(_appid)"
            UIApplication.shared.open(URL(string: commentsUrl)!, completionHandler: { (success) in
                debugPrint("recommend opened: \(success)") // Prints true
            })
        }
    }
}

// MARK: webview
extension MemberToolBox {
    /// 问卷调查
    /// - Parameters: 拉起问卷调查webview
    ///   - vc: 承载ViewController
    ///   - netUrl: 问卷链接
    public class func presentSuggestView(onViewController vc: UIViewController,
                                         suggestUrl netUrl: String?) {
        MemberToolBox.presentWebView(onViewController: vc, netUrl: netUrl, localFile: nil, title: "意见反馈")
    }
    
    
    /// 打开本地html文件
    /// - Parameters:
    ///   - vc: 承载ViewController
    ///   - fileName: 文件名
    ///   - title: webviewcollection 标题
    public class func presentWebPage(onViewController vc: UIViewController,
                                     fileName: String?,
                                     title: String?) {
        MemberToolBox.presentWebView(onViewController: vc, netUrl: nil, localFile: fileName, title: title)
    }
    
    /// 在线
    /// - Parameters: 拉起webview
    ///   - vc: 承载vc
    ///   - netUrl: url
    ///   - title: vc title
    public class func presentWebPage(onViewController vc: UIViewController,
                                     url netUrl: String? ,title: String?) {
        MemberToolBox.presentWebView(onViewController: vc, netUrl: netUrl, localFile: nil, title: title)
    }
    
    
    public class func presentWebView(onViewController vc: UIViewController,
                                     netUrl: String?,
                                     localFile: String?,
                                     title: String?) {
        let webview = WebKitViewController()
        webview.netUrl = netUrl
        webview.localFile = localFile
        webview.title = title
        if vc.navigationController != nil {
            vc.navigationController?.pushViewController(webview, animated: true)
        }else{
            vc.present(webview, animated: true, completion: { () -> Void in })
        }
    }
}


// MARK: const
extension MemberToolBox {
    /// 获取APPID （需要在info中配置 appid
    /// - Returns: appid
    public class func appId() -> String{
        let infoDictionary = Bundle.main.infoDictionary!
        guard let appid = infoDictionary["appid"] as? String else {
            assert(false, "必须在 info.plist 中配置 appid")
            return ""
        }
        return appid
    }
    
    /// 获取APP 名称 BundleName
    /// - Returns: APP 名称
    public  class func appName() -> String{
        let infoDictionary = Bundle.main.infoDictionary!
        guard let appid = infoDictionary["CFBundleName"] as? String else {
            return ""
        }
        return appid
    }
    
    /// 获取APP版本
    /// - Returns: APP版本
    public class func appVersion() -> String{
        let infoDictionary = Bundle.main.infoDictionary!
        guard let appid = infoDictionary["CFBundleShortVersionString"] as? String else {
            return "1.0"
        }
        return appid
    }
}
