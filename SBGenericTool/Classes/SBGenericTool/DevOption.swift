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
