import SwiftUI
import AVKit
import Foundation

struct ContentView: View {
    @StateObject var downloadManager = DownloadManager()

        var body: some View {
            VStack {
                if let player = downloadManager.player {
                    VideoPlayer(player: player)
                } else {
                    ProgressView(value: downloadManager.downloadProgress)
                }
            }
            .onAppear {
                let url = URL(string: "https://api.findawayworld.com/v4/audio/jX1t)WFF7jhHf3VIsShz3I5NXVGRvL4jlXU0Icm5oCIIAv4UFw9Gdat5TwcTpE1eXCNU(m0AWfezjxHd7PaSb8l4inCjRc25JeaPpK7PjdcXfbLfYJQDqDIKOQP347Sf4U)Gg24ytDY=.mp3")!
                let destinationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)
                downloadManager.downloadFile(from: url, to: destinationUrl)
            }
        }
}

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var player: AVPlayer?
    @Published var downloadProgress: Float = 0.0
    var destinationUrl: URL?

    func downloadFile(from url: URL, to destinationUrl: URL) {
        self.destinationUrl = destinationUrl
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let destinationUrl = destinationUrl else {
            return
        }
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("File already exists at \(destinationUrl)")
            self.player = AVPlayer(url: destinationUrl)
            return
        }
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            print("Downloaded file: \(location), to: \(destinationUrl)")
            DispatchQueue.main.async {
                self.player = AVPlayer(url: destinationUrl)
            }
        } catch {
            print("File error: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
                    self.downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                }
    }
}
