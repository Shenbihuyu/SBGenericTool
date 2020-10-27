//
//  DevOption.swift
//  Pods-SBGenericTool_Example
//
//  Created by 王剑鹏 on 2020/7/27.
//

import UIKit

public protocol UserDefaultsable {
    var saveKey : String { get }
}

extension UserDefaultsable {
    public var saveKey : String {
        return "com.shenbihuyu." + String(describing: self)
    }
}

/// 保存为 bool 类型
/// 显示在开发页面  带有一个开关控件
public protocol DevOptionSwitchable : UserDefaultsable {
    var  isOn : Bool { get }
    func setSwitch(isOn newValue: Bool)
}
extension DevOptionSwitchable {
    public var isOn : Bool {
        return UserDefaults.standard.object(forKey: saveKey) as? Bool ?? true
    }
    public func setSwitch(isOn newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: saveKey)
        UserDefaults.standard.synchronize()
    }
}

/// 保存为 Int类型
/// 显示在开发页面 可查看数值 ，带有一个归0按钮
public protocol DevOptionCountable : UserDefaultsable {
    var  count : Int { get }
    func setCount(_ count: Int)
}
extension DevOptionCountable {
    public var count: Int {
        return UserDefaults.standard.object(forKey: saveKey) as? Int ?? 0
    }
    public func setCount(_ count: Int) {
        UserDefaults.standard.set(count, forKey: saveKey)
        UserDefaults.standard.synchronize()
    }
}

/// 显示在开发页面 ，带有一个复制按钮
public protocol DevOptionCopyable : UserDefaultsable {
    var copyString: String { get }
}

/// 能够显示在 开发页面
public protocol DevOptionCellAble {
    var title  : String { get }
    var detail : String? { get }
}


/// 提供将indexPath 转换为 enum 生成方式
/// For example , `SettingCell`.
///
///     enum SettingCell: Int  IndexPathGeneticable {
///         static var minRow : Int { return 10 }
///         case xxx = 0 , yyy, zzz   // section = 0
///         case aaa = 10 , bb , cc   // section  = 1
///     }
///     let cell = SettingCell(indexPath: .init(row: 1, section: 1))
///     // cell == .bb  true
public protocol IndexPathGeneticable: RawRepresentable {
    
    /// 指定section转换时的系数, 默认为100
    static var minRow : Int { get }
}

extension RawRepresentable where Self : IndexPathGeneticable, Self.RawValue == Int {
    
    public static var minRow : Int { return 100 }
    
    /// return  .(rawValue: indexPath.section * Self.minRow + indexPath.row)
    /// - Parameter indexPath: indexPath
    public init?(indexPath: IndexPath) {
        if let type = Self.init(rawValue: (indexPath.section * Self.minRow + indexPath.row)) {
            self = type
        }else {
            return nil
        }
    }
}
