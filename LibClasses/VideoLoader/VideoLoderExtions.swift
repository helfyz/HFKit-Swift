//
//  VideoLoderExtions.swift
//  HFKit
//
//  Created by helfy on 2022/1/11.
//
import CommonCrypto
import Foundation

extension String {
    var filePathKey:String {
        let utf8 = cString(using: .utf8)
        var digest:[UInt8] = []
        if #available(iOS 13.0, *) {
            digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        } else {
            digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        }
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}

extension FileManager {
    static let cacheRootPath:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? ""

    func crearFileFolder(fileFolder:String) {
        if !fileExists(atPath: fileFolder) {
            try? createDirectory(atPath: fileFolder, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func subFiles(fileFolder:String) -> [String?]? {
        if fileExists(atPath: fileFolder) {
            let contents = try? contentsOfDirectory(atPath: fileFolder)
            return contents
        }
        return nil
    }
  
    static func cachePath(subPath:String) -> String {
        var subPath = subPath
        if subPath.hasPrefix("/") {
            subPath = String(subPath.dropFirst())
        }
        return FileManager.cacheRootPath + "/" + subPath
    }
   
}
