//
//  Downloader.swift
//  mixmax
//
//  Created by Apple on 4/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import RxSwift

class Download {
    
    var fileName: String?
    var fileId: String
    var urlString: String
    var localFileUrl: String?
    var task: URLSessionDownloadTask?
    var isDownloading = false {
        
        didSet {
            
            if !isDownloading { progress = 0 }
        }
    }
    
    var isDownloaded = false {
        
        didSet {
            
            if isDownloaded { progress = 0 }
        }
    }
    
    var size: String?
    var progress: Float = 0
    
    init(urlString: String, fileName: String?, fileId: String) {
        
        self.urlString = urlString
        self.fileName = fileName
        self.fileId = fileId
    }
}

class Downloader : NSObject, ItemDownload {
    
    static let shared = Downloader()

    lazy var downloadsSession: URLSession = {

        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var activeDownloads: Variable<[String: Download]> = Variable([:])
    
    func start(urlString: String, fileName: String?, fileId: String, token: String?) {
        
        if (activeDownloads.value.contains { $0.key == fileId }) { return }
        
        let request = Request(url: urlString, method: .get, token: token)
        
        let download = Download(urlString: urlString, fileName: fileName, fileId: fileId)
        
        download.task = downloadsSession.downloadTask(with: request.request)
        
        download.task!.resume()
        
        download.isDownloading = true
        

        activeDownloads.value[fileId] = download
    }
    
    
    func remove(fileId: String, localUrl: String, completed: (String) ->() ) {
        
        let download = activeDownloads.value.filter { $0.value.fileId == fileId }.first?.value
        
        if let download = download {
            
            download.isDownloading = false
            download.task?.cancel()
            activeDownloads.value[fileId] = download
        }
        
        let localPath = LocalPath()
        
        localPath.delete(localUrl: localUrl) { url in
            
            activeDownloads.value[fileId] = nil
            completed(url)
        }
        
    }
    
    func localFilePath(fileId: String?, fileName: String?) -> URL {
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let path = documentsPath.appendingPathComponent(fileName ?? "")
        
        if let fileId = fileId {
            
            let localPath = LocalPath()
            localPath.save(fileId: fileId, url: path.absoluteString)
        }
        
        return path
    }
}

// MARK: - URLSessionDelegate

extension Downloader : URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        print("#urlSessionDidFinishEvents")
    }
}

extension Downloader : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("#didFinishDownloadingTo")
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let downloadValue = activeDownloads.value.filter { $0.value.urlString == sourceURL.absoluteString }.first?.value
        guard let download = downloadValue else { return }

        
        let localFileUrl = localFilePath(fileId: download.fileId, fileName: download.fileName)
        print(localFileUrl)

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: localFileUrl)

        do {
            
            try fileManager.copyItem(at: location, to: localFileUrl)
            download.isDownloaded = true
            download.localFileUrl = localFileUrl.absoluteString
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        activeDownloads.value[download.fileId] = download
        activeDownloads.value[download.fileId] = nil

    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let downloadValue = activeDownloads.value.filter { $0.value.urlString == sourceURL.absoluteString }.first?.value
        guard let download = downloadValue else { return }
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        download.size = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        activeDownloads.value[download.fileId] = download
    }
}
