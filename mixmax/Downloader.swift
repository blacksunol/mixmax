//
//  Downloader.swift
//  mixmax
//
//  Created by Apple on 4/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

class Downloader : NSObject {
    
    func start() {
        
        let url = URL(string: "https://content.dropboxapi.com/2/files/download")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.addValue("Bearer mMH65aBfKgUAAAAAAAARn2gOn23w8-SSf7sYe-dm8NANCc_nLnopHt04yRqnHWPz", forHTTPHeaderField: "Authorization")
        request.addValue("{ \"path\": \"id:APg3ZTmBBHQAAAAAAAA68Q\"}", forHTTPHeaderField: "Dropbox-API-Arg")
        
        var downloadsSession: URLSession!
        
        downloadsSession.downloadTask(with: request)

    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func cancel() {
        
    }
    
    
    
}

extension Downloader : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        
    }
}
