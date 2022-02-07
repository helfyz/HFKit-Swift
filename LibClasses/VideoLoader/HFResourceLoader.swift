//
//  HFResourceLoader.swift
//  HFKit
//
//  Created by helfy on 2022/1/11.
//

import UIKit
import AVKit
import CommonCrypto

open class HFResourceLoader: NSObject {
    let resourceLoaderPerfix = "hf_"
 
    var curLoadingRequst:HFResourceLoadingRequst?
    open func playerItem(url:URL) -> AVPlayerItem? {
        guard let url = resourceLoaderAsset(url: url) else {
            return nil
        }
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        let item = AVPlayerItem(asset: asset)
        return item
    }
    private func resourceLoaderAsset(url:URL) -> URL? {
        URL(string: resourceLoaderPerfix + url.absoluteString)
    }
    private func originUrl(url:URL) -> URL? {
        URL(string: String(url.absoluteString.dropFirst(resourceLoaderPerfix.count)))
    }
}

extension HFResourceLoader: AVAssetResourceLoaderDelegate {
  
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        if let requstUrl = loadingRequest.request.url,
           requstUrl.absoluteString.hasPrefix(resourceLoaderPerfix),
           let url = originUrl(url: requstUrl ) {
            curLoadingRequst = HFResourceLoadingRequst(request: loadingRequest, originUrl: url)
            curLoadingRequst?.startLoading()
            return true
        }
       return false
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        curLoadingRequst?.cancelLoad()
    }

}
