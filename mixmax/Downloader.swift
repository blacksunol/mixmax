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
    
    var item: Item?
    var url: URL?
    var localPath: String?
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    var isDownloaded = false

    var progress: Float = 0
    
    init(item: Item?) {
        self.item = item
    }
}

class Downloader : NSObject, ItemDownload {
    
    static let shared = Downloader()

    lazy var downloadsSession: URLSession = {
//            let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var activeDownloads: Variable<[URL: Download]> = Variable([:])
    
    func start(item: Item?) {
        
        let urlStr = item?.track.url ?? ""
        
        if activeDownloads.value.contains(where: { $0.key.absoluteString == urlStr }) { return }

        let request = Request(url: urlStr, method: .get, token: item?.track.token)

        let url = URL(string: urlStr)!
        
        let download = Download(item: item)
        // 2
        download.task = downloadsSession.downloadTask(with: request.request)
        
        // 3
        download.task!.resume()
        // 4
        download.isDownloading = true
        // 5
        activeDownloads.value[url] = download
    }
    
    func pause(url: URL) {
        
        guard let download = activeDownloads.value[url] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func resume(url: URL) {
        
        guard let download = activeDownloads.value[url] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.url!)
        }
        download.task!.resume()
        download.isDownloading = true
    }
    
    func cancel(item: Item?) {
        
        guard let item = item else { return }
        let urlStr = item.track.url ?? ""

        let url = URL(string: urlStr)!
        
        if let download = activeDownloads.value[url] {
            
            download.task?.cancel()
            activeDownloads.value[url] = nil
        }
    }
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL, item: Item?) -> URL {
        
        let name = item?.name ?? ""
        let path = documentsPath.appendingPathComponent(name)
        
        if let localPath = item?.localPath {
            
            let localPath2 = LocalPath()
            localPath2.save(path: localPath, url: path.absoluteString)
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
        let destinationURL = localFilePath(for: sourceURL, item: download.item)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download.isDownloaded = true
            download.localPath = destinationURL.absoluteString
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

