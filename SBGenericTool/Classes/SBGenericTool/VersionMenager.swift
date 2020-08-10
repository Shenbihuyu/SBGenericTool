//
//  MemberToolBox.swift
//  SBVideoTool
//
//  Created by 王剑鹏 on 2020/6/10.
//  Copyright © 2020 Lete. All rights reserved.
//

import UIKit


//MARK: - 参数
public class VersionMenager: NSObject {
    public static let shared = VersionMenager()
    public var baseUrl = ""
    public var key = ""
    public var appName = ""
}

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
    class func checkVersion(completionHandler: @escaping (SBVersion?, Error?) -> Void) {
        assert(!Self.shared.baseUrl.isEmpty, "必须设置 VersionMenager.shared.baseUrl")
        assert(!Self.shared.appName.isEmpty, "必须设置 VersionMenager.shared.appName")
        assert(!Self.shared.key.isEmpty,     "必须设置 VersionMenager.shared.key")
        
        let version = MemberToolBox.appVersion()
        
        let urlStr = Self.shared.baseUrl +
            "control/" +
            [Self.shared.appName, Self.comefrom, version].joined(separator: "/")
        
        guard var urlComponents = URLComponents(string: urlStr) else {
            completionHandler(nil, NSError(domain: "链接错误", code: 10001, userInfo: nil))
            return
        }
        urlComponents.queryItems = networkParameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }

        guard let url = urlComponents.url else {
            completionHandler(nil, NSError(domain: "链接错误", code: 10001, userInfo: nil))
            return
        }
        var request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        let theSession = URLSession.shared
        let theTask = theSession.dataTask(with: request) { ( data, urlRespone, error) in
            do {
                guard let _data = data else { throw NSError(domain: "空数据", code: 10002, userInfo: nil) }
                let root = try JSONDecoder().decode(SBNetRootModel.self, from: _data)
                print(root.data)
                completionHandler(root.data, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        theTask.resume()
    }
    fileprivate struct SBNetRootModel: Codable {
        let data: SBVersion
        let code: Int
    }
}

// MARK:- model

public struct SBVersion: Codable {
    var auditStatus: Int = 0
    var advertStatus: Int = 0
    var versions: String?
    
    enum SBVersionCodingKeys: String, CodingKey {
        case auditStatus, advertStatus
        case versions
    }
}

// MARK:- save & load
public extension SBVersion {
    static let saveKey = "com.shenbi.version"
    func save() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self), forKey: Self.saveKey)
        UserDefaults.standard.synchronize()
    }
    static var `default`: SBVersion? {
        if let data = UserDefaults.standard.value(forKey: saveKey) as? Data ,
            let dict = try? PropertyListDecoder().decode(Self.self, from: data) {
            return dict
        }
        return nil
    }
    
    static var anquan : Bool {
        return Self.default?.auditStatus == 0
    }
    
    static var guanggao : Bool {
        return Self.default?.advertStatus == 0
    }
}

// MARK:- extension
extension Dictionary where Key == String, Value == Any {
    mutating func setSignature(_ sequence: String) {
        self["signature"] = sequence
            .components(separatedBy: ",")
            .reduce("", { (temp, key) -> String in
                if let value = self[key] as? String {
                    return temp + value
                }else if let value = self[key] as? Int {
                    return temp + String(value)
                }else if key == "key" {
                    return temp + VersionMenager.shared.key
                }else{
                    return temp
                }
            }).md5
    }
}

import CommonCrypto
extension String {
    var md5 : String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}



