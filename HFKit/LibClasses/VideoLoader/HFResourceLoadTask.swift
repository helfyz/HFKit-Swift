//
//  HFResourceLoaderTask.swift
//  HFKit
//
//  Created by helfy on 2022/1/14.
//

import UIKit
import AVKit
struct HFResourcePartLoaderTask {
    enum TaskType {
        case download
        case caches
    }
    let range: HFResourceFileRange
    let type: TaskType
    
}

/**
 */
class HFResourceLoadingRequst: NSObject {
  
    let resourceLoaderPerfix = "hf_"
    var loadingRequest:AVAssetResourceLoadingRequest
    var partTasks:[HFResourcePartLoaderTask] = []
    var cacheManger: HFResourceCache?
    let originUrl: URL
    
    init(request:AVAssetResourceLoadingRequest, originUrl:URL) {
        self.loadingRequest = request
        self.originUrl = originUrl
    }
    
    //开始加载
    func startLoading() {
        
        guard let requestedOffset = loadingRequest.dataRequest?.requestedOffset,
              let requestedLength = loadingRequest.dataRequest?.requestedLength else {
                  return
        }
    
        let requstRange = HFResourceFileRange.init(startIndex: requestedOffset, endIndex: requestedOffset + Int64(requestedLength) - 1)
        if cacheManger == nil  {
            cacheManger = HFResourceCache(url: originUrl)
            cacheManger?.creatFileDic()
        }
        // 如果有缓存的info信息。填充信息
        if let indoDic = NSDictionary(contentsOfFile: cacheManger!.infoFilePath()) as? Dictionary<String, Any>, indoDic.values.count > 0 {
            self.loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = indoDic["isByteRangeAccessSupported"] as? Bool ?? true
            self.loadingRequest.contentInformationRequest?.contentType = indoDic["contentType"] as? String ?? ""
            self.loadingRequest.contentInformationRequest?.contentLength = indoDic["contentLength"] as? Int64 ?? 0
        }
        let allRangs = cacheManger!.getAllCachesFileName()
        // 找到有交集的内容文件
        let pratRangs = allRangs?.filter{ requstRange.intersect(other: $0) }
        if let pratRangs = pratRangs {
            var tempStart = requstRange.startIndex
            pratRangs.forEach { range in
                if tempStart < range.startIndex {
                    partTasks.append(HFResourcePartLoaderTask(range: HFResourceFileRange(startIndex: tempStart, endIndex: range.startIndex), type: .download))
                    tempStart = range.startIndex + 1
               }
                partTasks.append(HFResourcePartLoaderTask(range:HFResourceFileRange(startIndex: tempStart, endIndex: min(range.endIndex, requstRange.endIndex)), type: .caches))
                if(requstRange.endIndex <= range.endIndex) {
                    tempStart = -1
                    return
                }
                tempStart = range.endIndex + 1
            }
            if tempStart != -1 {
                partTasks.append(HFResourcePartLoaderTask(range: HFResourceFileRange(startIndex: tempStart, endIndex: requstRange.endIndex), type: .download))
            }
        } else {
            partTasks.append(HFResourcePartLoaderTask(range: HFResourceFileRange(startIndex: requstRange.startIndex, endIndex: requstRange.endIndex), type: .download))
        }
        
        handleTasks()
    }
    
    // 取消加载
    func cancelLoad() {
        partTasks.removeAll()
    }

    
    private func fillContentInformation(response: HTTPURLResponse) {
        // 提取info
       
            var headers = [String: Any]()
            for key in response.allHeaderFields.keys {
                let lowercased = (key as! String).lowercased()
                headers[lowercased] = response.allHeaderFields[key]
            }
            var contentLength: Int64 = 0
            let isByteRangeAccessSupported = (headers["accept-ranges"] as? String) == "bytes"
            if let rangeText = headers["content-range"] as? String, let lengthText = rangeText.split(separator: "/").last {
                contentLength = Int64(lengthText)!
            } else {
                contentLength = Int64(headers["content-length"] as? String ?? "") ?? 0
            }
            
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = isByteRangeAccessSupported
        loadingRequest.contentInformationRequest?.contentType = response.mimeType
        loadingRequest.contentInformationRequest?.contentLength = contentLength
        
        let dic:NSMutableDictionary = NSMutableDictionary()
        dic["contentType"] = response.mimeType
        dic["contentLength"] = contentLength
        dic["isByteRangeAccessSupported"] = isByteRangeAccessSupported
        
        if let cacheManger = cacheManger {
            dic.write(toFile: cacheManger.infoFilePath(), atomically: true)
        }
       
    }
    
    private func handleTasks() {
        let tastQueue = OperationQueue()
        tastQueue.maxConcurrentOperationCount = 1
        partTasks.forEach { task in
            tastQueue.addOperation {[weak tastQueue] in
                if self.loadingRequest.isFinished {
                    tastQueue?.cancelAllOperations()
                }
                
                switch task.type {
                    case .caches:
                    guard let cacheManger = self.cacheManger else {
                            return
                    }
                    if let data = cacheManger.getData(range: task.range) {
                        self.loadingRequest.dataRequest?.respond(with: data)
                    } else {
                        self.loadingRequest.finishLoading(with: nil)
                    }
                        break
                    case .download:
                
                    let semaphore = DispatchSemaphore(value: 0)
                    let session: URLSession = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
                    var request = URLRequest(url: self.originUrl)
                    request.cachePolicy = .reloadIgnoringLocalCacheData
                    request.setValue("bytes=\(task.range.startIndex)-\(task.range.endIndex)", forHTTPHeaderField: "Range")
                    let task = session.dataTask(with: request) { data, response, error in
                            if self.loadingRequest.isCancelled {
                                semaphore.signal()
                                return
                            }
                         
                            if let response = response as? HTTPURLResponse {
                                self.fillContentInformation(response: response)
                            }
                            
                            if let data = data,let cacheManger = self.cacheManger {
                                self.loadingRequest.dataRequest?.respond(with: data)
                                cacheManger.saveCache(dataPart: HFResourceCachePart(data: data, range: task.range))
                            }
                            if let error = error {
                                self.loadingRequest.finishLoading(with: error)
                            }
                            semaphore.signal()
                        }
                        task.resume()
                        semaphore.wait()
                        break
                }
            }
        }
      
        tastQueue.addOperation {
            if !self.loadingRequest.isFinished && !self.loadingRequest.isCancelled {
                self.loadingRequest.finishLoading()
            }
        }
       
    }
    
}
