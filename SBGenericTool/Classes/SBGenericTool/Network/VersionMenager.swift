//
//  MemberToolBox.swift
//  SBVideoTool
//
//  Created by 王剑鹏 on 2020/6/10.
//  Copyright © 2020 Lete. All rights reserved.
//

import UIKit


//MARK: - 单例
public class VersionMenager: NSObject {
    public static let shared = VersionMenager()
    
    /// 服务器地址
    public var baseUrl = ""
    /// 加密key
    public var key = ""
    /// 应用名称
    public var appName = ""
}

//MARK: - 网络请求
public extension VersionMenager {
    fileprivate static let comefrom = "ios"
    fileprivate class var networkParameters : [String : Any] {
        var parameters = [String : Any]()
        parameters["appCode"]  = Self.shared.appName
        parameters["comefrom"] = Self.comefrom
        parameters["version"]  = MemberToolBox.appVersion()
        parameters["timestamp"] = String(Int(Date().timeIntervalSince1970))
        parameters.setSignature("appCode,comefrom,version,timestamp,key")
        return parameters
    }
    
    /// 检查后台的版本信息
    /// - Parameter completionHandler: 回调
    class func checkVersion(completionHandler: @escaping (SBVersion?, Error?) -> Void) {
        assert(!Self.shared.baseUrl.isEmpty, "必须设置 VersionMenager.shared.baseUrl")
        assert(!Self.shared.appName.isEmpty, "必须设置 VersionMenager.shared.appName")
        assert(!Self.shared.key.isEmpty,     "必须设置 VersionMenager.shared.key")
        
        let version = MemberToolBox.appVersion()
        
        guard var url = URL(string: Self.shared.baseUrl) else {
            completionHandler(nil, NSError(domain: "url error", code: 10001, userInfo: ["url": Self.shared.baseUrl]))
            return
        }
        url.appendPathComponent("control")
        url.appendPathComponent(Self.shared.appName)
        url.appendPathComponent(Self.comefrom)
        url.appendPathComponent(version)
        
        guard var urlComponents = URLComponents(string: url.absoluteString) else {
            completionHandler(nil, NSError(domain: "url error", code: 10001, userInfo: ["url": url.absoluteString]))
            return
        }
        
        urlComponents.queryItems = networkParameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
        guard let _url = urlComponents.url else {
            completionHandler(nil, NSError(domain: "url error", code: 10001, userInfo: ["parameters": networkParameters]))
            return
        }
        var request = URLRequest.init(url: _url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { ( data, urlRespone, error) in
            do {
                guard let _data = data else { throw NSError(domain: "no date", code: 10002, userInfo: nil) }
                let root = try JSONDecoder().decode(SBNetRootModel.self, from: _data)
                root.data.save()
                DispatchQueue.safe.async {
                    completionHandler(root.data, nil)
                }
            } catch {
                DispatchQueue.safe.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// 根数据
    fileprivate struct SBNetRootModel: Codable {
        let data: SBVersion
        let code: Int
    }
}

// MARK:- model

public struct SBVersion: Codable {
    public var auditStatus: Int = 0
    public var advertStatus: Int = 0
    public var adType : String = ADTypeDefault // admob (admob),buad(穿山甲)
    
    public init(audit: Int, advert: Int) {
        auditStatus = audit
        advertStatus = advert
    }
    
    enum CodingKeys: String, CodingKey {
        case auditStatus = "app_status"
        case advertStatus = "ad_status"
        case adType = "ad_type"
    }
}

let ADTypeDefault = "auto"
// MARK:- save & load
public extension SBVersion {
    static let saveKey = "com.shenbihuyu.version"
    
    /// 保存至UserDefaults
    func save() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self), forKey: Self.saveKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 读取本地UserDefaults
    static var `default`: SBVersion? {
        if let data = UserDefaults.standard.value(forKey: saveKey) as? Data ,
            let dict = try? PropertyListDecoder().decode(Self.self, from: data) {
            return dict
        }
        return nil
    }
    
    /// 是否安全
    static var anquan : Bool {
        guard let model = Self.default else { return false }
        return model.auditStatus == 0
    }
    
    /// 是否开启广告
    static var guanggao : Bool {
        guard let model = Self.default else { return false }
        return model.advertStatus != 0
    }
    
    /// 是否开启广告
    static var adType : String {
        guard let model = Self.default else { return ADTypeDefault }
        return model.adType
    }
}





