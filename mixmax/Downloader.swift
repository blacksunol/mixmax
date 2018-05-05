//
//  Downloader.swift
//  mixmax
//
//  Created by Apple on 4/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

class Download {
    
    var item: Item?
    var indexPath: IndexPath
    var url: URL?
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    var isDownloaded = false

    var progress: Float = 0
    
    init(item: Item?, indexPath: IndexPath) {
        self.item = item
        self.indexPath = indexPath
    }
}

protocol DownloaderDelegate {
    
    func updateProgress(download: Download)
}

class Downloader : NSObject, ItemDownload {
    
    static let shared = Downloader()

    lazy var downloadsSession: URLSession = {
//            let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var previewURL = URL(string: "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3")
    
    var activeDownloads: [URL: Download] = [:]
    
    var delegate: DownloaderDelegate?
    
    func start(item: Item?, indexPath: IndexPath) {
        
//        let url = URL(string: "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3")!
        let urlStr = item?.track.url ?? ""
        let url = URL(string: urlStr)!
        let download = Download(item: item, indexPath: indexPath)
        // 2
        download.task = downloadsSession.downloadTask(with: url)
        // 3
        download.task!.resume()
        // 4
        download.isDownloading = true
        // 5
        activeDownloads[url] = download

    }
    
    func pause(url: URL) {
        
        guard let download = activeDownloads[url] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func resume(url: URL) {
        guard let download = activeDownloads[url] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.url!)
        }
        download.task!.resume()
        download.isDownloading = true
    }
    
    func cancel(url: URL) {
        if let download = activeDownloads[url] {
            download.task?.cancel()
            activeDownloads[url] = nil
        }
    }
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent("abc.mp3")
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
        
//        // 1
//        guard let sourceURL = downloadTask.originalRequest?.url else { return }
//        let download = activeDownloads[sourceURL]
//        activeDownloads[sourceURL] = nil
//        // 2
//        let destinationURL = localFilePath(for: sourceURL)
//        print(destinationURL)
//        // 3
//        let fileManager = FileManager.default
//        try? fileManager.removeItem(at: destinationURL)
//        do {
//            try fileManager.copyItem(at: location, to: destinationURL)
//            download?.isDownloaded = true
//        } catch let error {
//            print("Could not copy file to disk: \(error.localizedDescription)")
//        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
      
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = activeDownloads[url]  else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
        // 4
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.updateProgress(download: download)
        }
    }
}

