//
//  DownloadService.swift
//  CSBC
//
//  Created by Luke Redmore on 2/12/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import PDFKit

// Downloads song snippets, and stores in local file.
// Allows cancel, pause, resume download.
class DownloadService {
    
    var activeDownloads: [URL: Download] = [:]
    
    // SearchViewController creates downloadsSession
    var downloadsSession: URLSession!
    
    // MARK: - Download methods called by TrackCell delegate methods
    
    func startDownload(_ doc: PDFToDownload) {
        // 1
        let download = Download(doc: doc, tag: doc.index)
        print(doc.previewURL)
        // 2
        download.task = downloadsSession.downloadTask(with: doc.previewURL)
        // 3
        download.task!.resume()
        // 4
        download.isDownloading = true
        // 5
        activeDownloads[download.doc.previewURL] = download

    }
    // TODO: previewURL is http://a902.phobos.apple.com/...
    // why doesn't ATS prevent this download?
    
    func pauseDownload(_ doc: PDFToDownload) {
        // TODO
    }
    
    func cancelDownload(_ doc: PDFToDownload) {
        // TODO
    }
    
    func resumeDownload(_ doc: PDFToDownload) {
        // TODO
    }
    
}
