//
//  WebKitViewController.swift
//  SBVideoTool
//
//  Created by 王剑鹏 on 2020/6/10.
//  Copyright © 2020 Lete. All rights reserved.
//

import UIKit
import WebKit


public class WebKitViewController: UIViewController, WKNavigationDelegate {
    public static let shared = WebKitViewController()
    
    public var netUrl : String? /// 网络链接
    public var localFile : String? /// 本地html
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(self.additionalSafeAreaInsets)
            } else {
                make.edges.equalToSuperview()
            }
        }
        self.view.addSubview(activityView)
        activityView.center = self.view.center
        self.activityView.stopAnimating()
        
        if let _netUrl = netUrl {
            self.activityView.startAnimating()
            let url = URL(string: _netUrl)!
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }else if let _localFile = localFile {
            let url = Bundle.main.url(forResource: _localFile, withExtension: "htm")!
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }else {
            let _ = infoLabel
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityView.stopAnimating()
    }
    
   public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let _url = navigationAction.request.url {
            if _url.absoluteString == self.netUrl {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
            return
        }
        decisionHandler(.cancel)
    }
    
    
    lazy var webView: WKWebView = {
        let webview = WKWebView()
        webview.navigationDelegate = self
        return webview
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "链接无效"
        label.font = .systemFont(ofSize: 30)
        label.textColor = UIColor.lightGray
        self.view.addSubview(label)
        label.sizeToFit()
        label.center = self.view.center
        return label
    }()
    /// 菊花圈
    lazy var activityView : UIActivityIndicatorView = { [weak self] in
        let layer = CALayer()
        let activityView = UIActivityIndicatorView()
        activityView.startAnimating()
        activityView.hidesWhenStopped = true
        
        if #available(iOS 13.0, *) {
            activityView.style = .whiteLarge
        } else {
            activityView.style = .white
        }
        layer.backgroundColor = UIColor(white: 0.3, alpha: 0.7).cgColor
        layer.cornerRadius = 15.0
        activityView.layer.insertSublayer(layer, at: 0)
        let height = (layer.frame.width) / 2
        layer.frame = CGRect(x: -50+height, y: -50+height, width: 100, height: 100)
        return activityView
        }()
    
}
