//
//  MemberToolBox.swift
//  SBVideoTool
//
//  Created by 王剑鹏 on 2020/6/10.
//  Copyright © 2020 Lete. All rights reserved.
//

import UIKit
import StoreKit

public class MemberToolBox: NSObject {
    public static let shared = MemberToolBox()
}


// StoreKit
// APP内打开AppStore
extension MemberToolBox: SKStoreProductViewControllerDelegate {
    
    ///  在APP内拉起 AppStore页面
    ///     有传入vc: 先尝试拉起 AppStoreProductViewController ， 拉起失败将跳转到 APP Store
    ///     没有传入vc: 将立刻跳转到 APP Store
    ///
    ///     由于需要联网读取APP信息，可以添加loading 并在 completionHandler 里取消
    ///
    /// - Parameters:
    ///   - appid: 需要跳转的APPID
    ///   - viewController: 页面承接vc
    ///   - completionHandler: 回调true: 成功跳转或者成功加载数据，false: appid无效或无法跳转
    public func recommendAtAppStore(appid: String?,
                                    on viewController: UIViewController? = nil,
                                    completionHandler: ((_ success: Bool)->Void)? = nil) {
        guard let _appid = appid else {
            completionHandler?(false)
            return
        }
        let openUrl = {
            let commentsUrl = "itms-apps://itunes.apple.com/cn/app/id\(_appid)"
            UIApplication.shared.open(URL(string: commentsUrl)!, completionHandler: { (success) in
                debugPrint("recommend opened: \(success)") // Prints true
                completionHandler?(success)
            })
        }
        if let _viewController = viewController {
            let skVC = SKStoreProductViewController()
            skVC.delegate = self
            skVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : _appid]) { (result, error) in
                if !result {
                    openUrl()
                }else {
                    completionHandler?(result)
                    _viewController.present(skVC, animated: false)
                }
            }
        }else{
            openUrl()
        }
    }
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: 分享与评论
extension MemberToolBox{
    /// 分享该APP
    /// - Parameters:
    ///   - vc: 弹窗ViewController
    ///   - sourceView: 支持iPad的必须传入
    public class func shareApp(onViewController vc:UIViewController, sourceView: UIView? = nil) {
        let textToShare = MemberToolBox.appName()
        let imageToShare = UIImage.init(named: "icon")
        let urlToShare = NSURL.init(string: "https://apps.apple.com/cn/app/id" + MemberToolBox.appId())
        let items = [textToShare,imageToShare as Any,urlToShare as Any] as [Any]
        var exclude:[UIActivity.ActivityType] = [.message, .airDrop, .mail, .assignToContact,
                                                 .postToVimeo, .print, .copyToPasteboard, .saveToCameraRoll,
                                                 .postToFlickr, .openInIBooks, .addToReadingList]
        if #available(iOS 11.0, *) {
            exclude.append(UIActivity.ActivityType.markupAsPDF)
        }
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = sourceView
        }
        activityVC.excludedActivityTypes = exclude
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            if success {
                
            }
        }
        vc.present(activityVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    
    /// 去苹果商店评论
    public class func commentsAtAppStore(completionHandler: ((_ success: Bool)->Void)? = nil ) {
        let appid = MemberToolBox.appId()
        let commentsUrl = "itms-apps://itunes.apple.com/cn/app/id\(appid)?mt=8&action=write-review"
        UIApplication.shared.open(URL(string: commentsUrl)!, completionHandler: { (success) in
            debugPrint("comments opened: \(success)")
            completionHandler?(success)
        })
    }
    
    
    /// 推荐APP - 跳转到应用商店
    /// - Parameter appid: 推荐APP的APPID
    public class func recommendAtAppStore(recommendAppid appid: String?,
                                          completionHandler: ((_ success: Bool)->Void)? = nil) {
        if let _appid = appid {
            let commentsUrl = "itms-apps://itunes.apple.com/cn/app/id\(_appid)"
            UIApplication.shared.open(URL(string: commentsUrl)!, completionHandler: { (success) in
                debugPrint("recommend opened: \(success)") // Prints true
                completionHandler?(success)
            })
        }
    }
}

// MARK: version
extension MemberToolBox {
    public typealias VersionCompletion = ((_ version: String?)->())
    /// 检查版本号
    /// 通过Bundle ID获取商店版本号
    /// - Parameter completion: version : 商店版本号
    public class func checkAppStoreVersion(completion: MemberToolBox.VersionCompletion?) {
        func mainQueueCallback(_ version: String?) {
            DispatchQueue.main.async {
                completion?(version)
            }
        }
         
        let bundleIdentifire = MemberToolBox.appBundleID()
        if bundleIdentifire.count == 0 {
            debugPrint("No Bundle Info found.")
            completion?(nil)
        }
        // Build App Store URL
        guard let url = URL(string:"http://itunes.apple.com/lookup?bundleId=" + bundleIdentifire) else {
            debugPrint("Isse with generating URL.")
            completion?(nil)
            return
        }
        let serviceTask = URLSession.shared.dataTask(with: url) { (responseData, response, error) in
            do {
                if let error = error { throw error }
                if let data = responseData,
                    let resultData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                    let results = resultData["results"] as? [[String : Any]],
                    let result = results.first,
                    let version = result["version"] as? String {
                    mainQueueCallback(version)
                }else {
                    mainQueueCallback(nil)
                }
            } catch {
                mainQueueCallback(nil)
            }
        }
        serviceTask.resume()
    }
    
    /// 更新APP - 跳转到应用商店
    public class func updataAtAppStore() {
        let appid = MemberToolBox.appId()
        let commentsUrl = "itms-apps://itunes.apple.com/cn/app/id\(appid)"
        UIApplication.shared.open(URL(string: commentsUrl)!, completionHandler: { (success) in
            debugPrint("updata opened: \(success)") // Prints true
        })
        
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
                                     url netUrl: String?, title: String?) {
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
    public class func appName() -> String{
        let infoDictionary = Bundle.main.infoDictionary!
        guard let appid = infoDictionary["CFBundleName"] as? String else {
            return ""
        }
        return appid
    }
    
    /// 获取APP 名称 BundleId
    /// - Returns: APP Bundle ID 名称
    public class func appBundleID() -> String {
        let infoDictionary = Bundle.main.infoDictionary!
        guard let appid = infoDictionary["CFBundleIdentifier"] as? String else {
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
