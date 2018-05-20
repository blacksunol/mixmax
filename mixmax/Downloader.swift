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
    var fileId: String?
    var urlString: String?
    var destinationUrl: String?
    var task: URLSessionDownloadTask?
    var isDownloading = false
    
    var isDownloaded = false

    var progress: Float = 0
    
    init(urlString: String?, fileName: String?, fileId: String?) {
        
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
    
    var activeDownloads: Variable<[URL: Download]> = Variable([:])
    
    func start(urlString: String?, fileName: String?, fileId: String?, token: String?) {
        
        guard let urlString = urlString else { return }
        
        if activeDownloads.value.contains(where: { $0.key.absoluteString == urlString }) { return }

        let request = Request(url: urlString, method: .get, token: token)
        
        let download = Download(urlString: urlString, fileName: fileName, fileId: fileId)
        
        download.task = downloadsSession.downloadTask(with: request.request)
        
        download.task!.resume()
        
        download.isDownloading = true
        
        let url = URL(string: urlString)!

        activeDownloads.value[url] = download
    }
    
    
    func remove(item: Item?, completed: (String) ->() ) {
        
        guard let item = item else { return }
        let urlStr = item.track.url ?? ""
        
        let url = URL(string: urlStr)!
        
        if let download = activeDownloads.value[url] {
            download.isDownloading = false
            download.task?.cancel()
            activeDownloads.value[url] = download

        }
        
        let localPath = LocalPath()
        let localUrl = item.track.localUrl ?? ""
        
        localPath.delete(url: localUrl) { url in
            
            completed(url)
        }
        activeDownloads.value[url] = nil

    }
    
    func localFilePath(fileId: String?, fileName: String?) -> URL {
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let path = documentsPath.appendingPathComponent(fileName ?? "")
        
        if let fileId = fileId {
            
            let localPath2 = LocalPath()
            localPath2.save(fileId: fileId, url: path.absoluteString)
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
        
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        guard let download = activeDownloads.value[sourceURL]  else { return }
        // 2
        let destinationURL = localFilePath(fileId: download.fileId, fileName: download.fileName)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)

        do {
            
            try fileManager.copyItem(at: location, to: destinationURL)
            download.isDownloaded = true
            download.destinationUrl = destinationURL.absoluteString
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        activeDownloads.value[sourceURL] = download
        activeDownloads.value[sourceURL] = nil

    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
      
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = activeDownloads.value[url]  else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        activeDownloads.value[url] = download
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
    }
}
