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
    
    public convenience init(netHex:Int, alpha: CGFloat = 1) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, alpha: alpha)
    }
    
    public convenience init(strHex: String, alpha: CGFloat = 1) {
        var cString:String = strHex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        var rgbValue : UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        if cString.count == 6 {
            self.init(netHex: Int(rgbValue), alpha: alpha)
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
    
    
    /// 生成带有偏移量图片
    /// - Parameter offset: 偏移量
    /// - Returns: 新图片
    func movePosition(offset: CGPoint) -> UIImage {
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 2)
        self.draw(in: CGRect(x: offset.x, y: offset.y, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

//MARK: - 导航栏
extension UIApplicationDelegate {
    
    /// 全局设置导航栏状态
    /// - Parameters:
    ///   - backgroundColor: 背景颜色
    ///   - tintColor: 导航栏标题与按钮颜色
    ///   - imageName: 返回按钮图片
    ///   - offset: 返回按钮图标偏移
    ///   - clearShadow: 是否替换分割线
    public func setUpNavigationBar(backgroundColor : UIColor = .white,
                              tintColor : UIColor = UIColor.black,
                              imageName : String = "nb_back",
                              offset: CGPoint = .zero,
                              clearShadow: Bool = true) {
        var backButtonImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
//        backButtonImage = backButtonImage?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 10)
        backButtonImage = backButtonImage?.movePosition(offset: offset)
        
        let backgroundImage = UIImage.init(color: .clear)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // 背景颜色
            appearance.backgroundColor = backgroundColor
            if clearShadow {
                appearance.shadowImage = backgroundImage
            }
            // 控件颜色
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: tintColor as Any
            ]
            // 返回按钮
            appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor as Any]
            appearance.buttonAppearance = buttonAppearance
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UIBarButtonItem.appearance().tintColor = tintColor
        } else {
            // 背景颜色
            UINavigationBar.appearance().barTintColor = backgroundColor
            if clearShadow {
                UINavigationBar.appearance().shadowImage = backgroundImage
            }
            // 控件颜色
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: tintColor as Any
            ]
            UINavigationBar.appearance().tintColor = tintColor
            // 返回按钮
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

class NoUse {}
//MARK: - pod内多语言
extension String{
    var SBlocalized: String {
//        let bundlePaths = Bundle(for: NoUse.self).paths(forResourcesOfType: "bundle", inDirectory: nil)
        guard let resourcePath = Bundle(for: NoUse.self).path(forResource: "SBGenericTool", ofType: "bundle"),
              let resourceBundle = Bundle(path: resourcePath) // 资源包
        else {
            return self
        }
        if let userLanguage = SBServerMenager.shared.language, //有设置本地语言
           let path = resourceBundle.path(forResource: userLanguage, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            let newStr = NSLocalizedString(self, tableName: nil, bundle: languageBundle, value: "", comment: "")
            return newStr
        }
        let newStr = NSLocalizedString(self, tableName: nil, bundle: resourceBundle, value: "", comment: "")
        return newStr
    }
}

public extension UIDevice {
    //设备名称
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

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
        let specificValue = "com.shenbihuyu.mainQueue.specific"
        static let `default` = DispachQueueSafety()
    }
    
    /// 安全线程
    /// 自动选择在主线程运行
    /// 避免主线程 调用 DispatchQueue.main.async 崩溃
    public static var safe : DispachQueueSafety {
        return DispachQueueSafety.default
    }
}
