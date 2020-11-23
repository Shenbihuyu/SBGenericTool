//
//  SBNetworkModel.swift
//  SBGenericTool
//
//  Created by 王剑鹏 on 2020/10/27.
//

import UIKit

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

// MARK:- extension
extension Dictionary where Key == String, Value == Any {
    
    /// 给dict设置签名
    /// - Parameters:
    ///   - sequence: 签名顺序， 多个参数 用 , 隔开:  "app,server,version,key"
    ///   - signatureKey: md5盐值
    /// 
    mutating func setSignature(_ sequence: String, signatureKey: String = SBServerMenager.shared.key) {
        self["signature"] = sequence
            .components(separatedBy: ",")
            .reduce("", { (temp, key) -> String in
                if let value = self[key] as? String {
                    return temp + value
                }else if let value = self[key] as? Int {
                    return temp + String(value)
                }else if key == "key" {
                    return temp + signatureKey
                }else{
                    return temp
                }
            }).md5
    }
    
    /// 将参数进行编码 返回date，用于httpbody
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
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
