//
//  Extension.swift
//  Pods-SBGenericTool_Example
//
//  Created by 王剑鹏 on 2020/7/28.
//

import UIKit

//MARK: - 颜色
extension UIColor {
    
    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        assert(red   >= 0 && red   <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue  >= 0 && blue  <= 255, "Invalid blue component")
        self.init(red:   CGFloat(red)   / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue:  CGFloat(blue)  / 255.0,
                  alpha: alpha)
    }
    
    public convenience init(netHex:Int ,alpha: CGFloat = 1) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, alpha: alpha)
    }
    
    public convenience init(strHex: String) {
        var cString:String = strHex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        var rgbValue : UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        if cString.count == 6 {
            self.init(netHex: Int(rgbValue))
        }else if cString.count == 8 {
            self.init(netHex: Int(rgbValue >> 8), alpha: CGFloat(rgbValue & 0xff) / 255.0)
        }else{
            self.init(netHex: 0x000000) // 返回黑色
        }
    }

    /// 随机颜色 用于测试
    open class var randomColor : UIColor {
        let hue = CGFloat(arc4random()%100)/100.0
        return UIColor(hue: hue, saturation: 0.85, brightness: 0.85, alpha: 1)
    }
    
}
//MARK: - 图片
extension UIImage {
    /// 根据颜色生成纯色图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片尺寸
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//MARK: - 导航栏
extension UIApplicationDelegate {
    
    /// 全局设置导航栏状态
    /// - Parameters:
    ///   - backgroundColor: 背景颜色
    ///   - tintColor: 导航栏标题与按钮颜色
    ///   - imageName: 返回按钮图片
    public func setUpNavigationBar(backgroundColor : UIColor = .white,
                              tintColor : UIColor = UIColor.black,
                              imageName : String = "nb_back") {
        var backButtonImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        backButtonImage = backButtonImage?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 10)
        
        let backgroundImage = UIImage.init(color: backgroundColor)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            appearance.shadowImage = backgroundImage
            appearance.setBackIndicatorImage(backgroundImage, transitionMaskImage: backgroundImage)
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: tintColor as Any
            ]
            appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor as Any]
            appearance.buttonAppearance = buttonAppearance
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UIBarButtonItem.appearance().tintColor = tintColor
        } else {
            UINavigationBar.appearance().barTintColor = backgroundColor
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: tintColor as Any
            ]
            UINavigationBar.appearance().tintColor = tintColor
            UINavigationBar.appearance().shadowImage = backgroundImage
            UINavigationBar.appearance().backIndicatorImage = backButtonImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        }
    }
}

//MARK: - 多语言
extension String {
    
    /// 获取多语言文本
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    /// 获取多语言文本
    /// - Parameter comment: 注释
    public func localized(withComment comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
}

//MARK: - 安全线程
extension DispatchQueue {
    public struct DispachQueueSafety {
        private init() {
            DispatchQueue.main.setSpecific(key: specificKey, value: specificValue)
        }
        private var isMainQueue: Bool {
            return DispatchQueue.getSpecific(key: specificKey) == specificValue
        }
        public func async(execute: @escaping () -> Void) {
            isMainQueue ? execute() : DispatchQueue.main.async(execute: execute)
        }
        let specificKey = DispatchSpecificKey<String>()
        let specificValue = "com.dumbass.mainQueue.specific"
        static let `default` = DispachQueueSafety()
    }
    
    /// 安全线程
    /// 自动选择在主线程运行
    /// 避免主线程 调用 DispatchQueue.main.async 崩溃
    public static var safe : DispachQueueSafety {
        return DispachQueueSafety.default
    }
}
