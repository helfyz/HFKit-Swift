//
//  HFResourceCache.swift
//  HFKit
//
//  Created by helfy on 2022/1/14.
//

import UIKit

struct HFResourceCachePart {
    var data:Data
    var range:HFResourceFileRange
}

struct HFResourceFileRange {
    var startIndex: Int64
    var endIndex: Int64
    
    static func ~= (left:HFResourceFileRange, index:Int64) -> Bool {
        return index >= left.startIndex && index <= left.endIndex
    }
    
    // 是否有相交的部分
    func intersect(other:HFResourceFileRange) -> Bool {
        let ranges = [self, other].sorted { $0.startIndex < $1.startIndex }
        return ranges.first!.endIndex - ranges.last!.startIndex > 0
    }
    
    // 相交的部分
    func intersectRange(other:HFResourceFileRange) -> HFResourceFileRange? {
        let maxStart = max(self.startIndex, other.startIndex)
        let minEnd = min(self.endIndex, other.endIndex)
        if maxStart < minEnd { //有效的范围
            return HFResourceFileRange(startIndex:maxStart, endIndex:minEnd)
        }
        return nil
   }
    
    // 完全包含另外一个
    func containRange(other:HFResourceFileRange) -> Bool {
        self.startIndex <= other.startIndex && self.endIndex >= other.endIndex
   }

}

class HFResourceCache: NSObject {
    // 文件信息
    let info:Dictionary<String, Any> = [:]
    var fileManger = FileManager.default
   
    let resourceUrl: URL
    let fileFloderPath :String
    
    init(url:URL) {
        self.resourceUrl = url
        self.fileFloderPath = FileManager.cachePath(subPath: self.resourceUrl.absoluteString.filePathKey)
    }
    
    
    // 创建缓存文件目录
    func creatFileDic() {
        fileManger.crearFileFolder(fileFolder: fileFloderPath)
    }
    
    func cacheFile(range:HFResourceFileRange) -> String {
        self.fileFloderPath + "/" + "\(range.startIndex)-\(range.endIndex)"
    }
    func infoFilePath() -> String! {
        self.fileFloderPath + "/" + "info.plist"
    }
    
    
    // 保存分段data内容，
    func saveCache(dataPart:HFResourceCachePart) {
        DispatchQueue.hf.async {
            let filePath = self.cacheFile(range: dataPart.range)
            self.fileManger.createFile(atPath: filePath, contents: dataPart.data, attributes: nil)
        }
    }
    
    // 通过范围获取data  缓存中有完整的data
    func getData(range:HFResourceFileRange) -> Data? {
        if let fileName = getFileName(range: range) {
          return try? Data.init(contentsOf: URL(fileURLWithPath: fileName))
        }
        return nil
    }
    
    func getFileName(range:HFResourceFileRange) -> String? {
        let allFileName = self.getAllCachesFileName()
        let result = allFileName?.first(where: { tempRange in
            tempRange.containRange(other: range)
        })
        guard let result = result else {
            return nil
        }
        return fileFloderPath + "/" + "\(result.startIndex)-\(result.endIndex)"
    }
    
    func getAllCachesFileName() -> [HFResourceFileRange]?  {
        let files = fileManger.subFiles(fileFolder: self.fileFloderPath)
        var ranges:[HFResourceFileRange] = []
        if let files = files {
            files.forEach { fileName in
                if let range = fileName?.components(separatedBy: "-"), range.count >= 2 {
                    if let start = Int64(range[0]), let end = Int64(range[1]) {
                        let range = HFResourceFileRange(startIndex: start, endIndex: end)
                        ranges.append(range)
                    }
                }
            }
        }
        ranges = ranges.sorted {
            $0.startIndex < $1.startIndex
        }
        return ranges
    }
}
