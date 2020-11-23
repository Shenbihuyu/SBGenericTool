//
//  SBServerMenager.swift
//  SBGenericTool
//
//  Created by 王剑鹏 on 2020/10/21.
//

import UIKit

//MARK: - 单例
public class SBServerMenager: NSObject {
    public static let shared = SBServerMenager()
    
    /// 服务器地址
    public var baseUrl = ""
    /// 加密key
    public var key = ""
    /// 应用名称
    public var appName = ""
    
    public var machineid = ""
    
    public var uid = ""
    
    public var language : String? 
}

public extension SBServerMenager {
    fileprivate static let comefrom = "ios"
    
    /// 请求用基础参数
    fileprivate class var networkParameters : [String : Any] {
        var parameters = [String : Any]()
        parameters["app_code"]   = Self.shared.appName
        parameters["comefrom"]   = Self.comefrom
        parameters["machineid"]  = Self.shared.machineid
        parameters["ip"]         = "0"
        parameters["timestamp"]  = String(Int(Date().timeIntervalSince1970 * 1000))
        parameters["system"]     = UIDevice.current.systemVersion
        parameters["models"]     = UIDevice.modelName
        parameters["uid"]        = Self.shared.uid
        parameters["version"]    = MemberToolBox.appVersion()
        parameters.setSignature("appCode,comefrom,version,timestamp,key")
        return parameters
    }
    
    /// 获取推荐APP列表
    /// - Parameter completionHandler: 网络请求回调
    class func loadRecommendAppList(completionHandler: @escaping ([SBAppModel]?, Error?) -> Void) {
        checkNetParameter()
        
        guard var url = URL(string: Self.shared.baseUrl) else {
            completionHandler(nil, NSError(domain: "url error", code: 10001, userInfo: ["url": Self.shared.baseUrl]))
            return
        }
        url.appendPathComponent("data/recommend")
        url.appendPathComponent(Self.shared.appName)
        url.appendPathComponent(Self.comefrom)

        
        var request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.setValue(shared.language, forHTTPHeaderField: "Language")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { ( data, urlRespone, error) in
            DispatchQueue.safe.async {
                do {
                    guard let _data = data else { throw NSError(domain: "no date", code: 10002, userInfo: ["url": url]) }
                    let root = try JSONDecoder().decode(SBNetRootModel<[SBAppModel]>.self, from: _data)
                    completionHandler(root.data, nil)
                }catch {
                    completionHandler(nil, error)
                }
            }
        }.resume()
    }
    
    /// 发送意见反馈
    /// - Parameters:
    ///   - message: 消息主体
    ///   - contact: 联系方式
    ///   - completionHandler: 网络回调
    class func feedback(message : String, contact: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        
        checkNetParameter()
        checkMachineid()
        
        guard var url = URL(string: Self.shared.baseUrl) else {
            completionHandler(false, NSError(domain: "url error", code: 10001, userInfo: ["url": Self.shared.baseUrl]))
            return
        }
        url.appendPathComponent("data/feedback")
         
        var _networkParameters = networkParameters
        _networkParameters["message"] = message
        _networkParameters["contact"] = contact
        _networkParameters.setSignature("app_code,comefrom,message,contact,timestamp,machineid,ip,key",
                                        signatureKey: Self.shared.key)
        
        
        var request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.setValue(shared.language, forHTTPHeaderField: "Language")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = _networkParameters.percentEncoded()
        
        URLSession.shared.dataTask(with: request) { ( data, urlRespone, error) in
            DispatchQueue.safe.async {
                do {
                    guard let _data = data else { throw NSError(domain: "no date", code: 10002, userInfo: nil) }
                    let root = try JSONDecoder().decode(SBNetRootModel<SBNetNilModel>.self, from: _data)
                    completionHandler(root.rst == 1000, nil)
                }catch {
                    completionHandler(false, error)
                }
            }
        }.resume()
    }
    
    class func checkNetParameter() {
        assert(!Self.shared.baseUrl.isEmpty, "必须设置 SBServerMenager.shared.baseUrl")
        assert(!Self.shared.appName.isEmpty, "必须设置 SBServerMenager.shared.appName")
        assert(!Self.shared.key.isEmpty,     "必须设置 SBServerMenager.shared.key")
    }
    
    class func checkMachineid() {
        assert(!Self.shared.machineid.isEmpty, "必须设置 SBServerMenager.shared.machineid")
    }
    
    /// 根数据
    fileprivate struct SBNetRootModel<T : Codable>: Codable {
        let data: T?
        let rst: Int
        let msg: String?
    }
    fileprivate struct SBNetNilModel: Codable { }
}

public extension SBServerMenager {
    /// 版本检查
    class func checkVersion(completionHandler: @escaping (SBVersion?, Error?) -> Void) {
        guard var url = URL(string: Self.shared.baseUrl) else {
            completionHandler(nil, NSError(domain: "url error", code: 10001, userInfo: ["url": Self.shared.baseUrl]))
            return
        }
        url.appendPathComponent("data/config/")
        url.appendPathComponent(Self.shared.appName)
        url.appendPathComponent(Self.comefrom) // comefrom
        url.appendPathComponent(Self.comefrom) // channel
        url.appendPathComponent(MemberToolBox.appVersion())
        
        var request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.setValue(shared.language, forHTTPHeaderField: "Language")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { ( data, urlRespone, error) in
            DispatchQueue.safe.async {
                do {
                    guard let _data = data else { throw NSError(domain: "no date", code: 10002, userInfo: ["url": url]) }
                    let root = try JSONDecoder().decode(SBNetRootModel<SBVersion>.self, from: _data)
                    root.data?.save()
                    completionHandler(root.data, nil)
                }catch {
                    completionHandler(nil, error)
                }
            }
        }.resume()
    }
}

public struct SBAppModel : Codable {
    public var app_code: String
    public var desc: String?
    public var name: String
    public var icon_url: String?
    public var down_url: String?
}



