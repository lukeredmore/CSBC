//
//  ViewController+URLSessionDelegates.swift
//  CSBC
//
//  Created by Luke Redmore on 2/12/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

extension ViewController: URLSessionDownloadDelegate {
    
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        func localFilePath(for url: URL) -> URL {
            return documentsPath.appendingPathComponent(url.lastPathComponent)
        }
        
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        // 2
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.doc.downloaded = true
            if let downloadedPDF = PDFDocument(url: destinationURL) {
                loadedDocs.updateValue(downloadedPDF, forKey: (download?.tag)!)
            }
            
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }

    }
}
