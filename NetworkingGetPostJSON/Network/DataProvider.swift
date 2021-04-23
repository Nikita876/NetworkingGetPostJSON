//
//  DataProvider.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 23.04.21.
//

import UIKit

class DataProvider: NSObject {
    // MARK: - Variables
    private var downloadTask: URLSessionDownloadTask!
    var fileLocation: ((URL) -> ())?
    var onProgress: ((Double) -> ())?
    private lazy var backgroundSession: URLSession = {
        /// поведение для заргузки и выгрузки данных
        let config = URLSessionConfiguration.background(withIdentifier: "ru.swiftbook.Network")
        /// могут ли фотовые задачи быть запланированы по усмотрению системы для оптимальной производительности
        config.isDiscretionary = true
        /// по завершения загрузки данных приложение запустится в фоновом режиме
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    // MARK: - Methods
    /// startDownload
    func startDownload() {
        
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin") {
            downloadTask = backgroundSession.downloadTask(with: url)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            downloadTask.countOfBytesClientExpectsToSend = 512
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024
            downloadTask.resume()
        }
    }
    
    /// stoptDownload
    func stopDownload() {
        downloadTask.cancel()
    }
}
// MARK: - DataProvider: URLSessionDelegate
extension DataProvider: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        DispatchQueue.main.async {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler
            else { return }
            
            appDelegate.backgroundSessionCompletionHandler = nil
            completionHandler()
        }
    }
}

// MARK: -
extension DataProvider: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("Did finish downloading: \(location.absoluteString)")
        
        DispatchQueue.main.async {
            self.fileLocation?(location)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        
        let progress = Double(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
        print("Download progress: \(progress)")
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
}
