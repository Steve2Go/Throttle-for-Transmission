//#if os(iOS)
//
//import SwiftUI
//
//struct StoredThumbnail {
//    let id: Int
//    let url: URL?
//}
//
//struct ListThumb: View {
//    @State var torrent: Torrent
//    @ObservedObject var store: Store // Changed to ObservedObject
//    @State var config: TransmissionConfig
//    @State var auth: TransmissionAuth
//    @State private var retryAttempt = 0
//    private let maxRetries = 3
//    private let retryDelay: Double = 60
//    
//    private let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "jfif", "bmp"]
//    private let videoExtensions: Set<String> = ["mp4", "mov", "avi", "mkv", "flv", "mpeg", "m4v"]
//    
//    var body: some View {
//        VStack {
//            if let storedThumb = store.storedThumbnails[torrent.id] {
//                if let url = storedThumb.url {
//                    if isImage(url: url) {
//                        ImageThumbnailView(imageURL: url)
//                    } else if isVideo(url: url) {
//                        VideoThumbnailView(videoURL: url)
//                    } else {
//                        placeholder
//                    }
//                } else {
//                    placeholder
//                }
//            } else {
//                placeholder
//            }
//        }
//        .onAppear {
//            checkThumbnail()
//        }
//    }
//    
//    private var placeholder: some View {
//        Image(systemName: "arrow.down.document")
//            .imageScale(.medium)
//            .foregroundColor(.primary)
//            .frame(width: 70, height: 70)
//            .scaledToFill()
//    }
//    
//    private func checkThumbnail() {
//        guard store.storedThumbnails[torrent.id] == nil else { return }
//        
//        getTransferFiles(transferId: store.transferToOpenFiles!, info: (config, auth)) { files, success, _ in
//            guard success, let files = files else {
//                scheduleRetry()
//                return
//            }
//            
//            processFiles(files)
//            
//            if store.storedThumbnails[torrent.id] == nil {
//                scheduleRetry()
//            }
//        }
//    }
//    
//    private func processFiles(_ files: [FileWithId]) {
//        let mediaFile = files.first { file in
//            let ext = URL(fileURLWithPath: file.name).pathExtension.lowercased()
//            return imageExtensions.contains(ext) || videoExtensions.contains(ext)
//        }
//        
//        if let file = mediaFile,
//           let url = URL(string: buildURL(for: file.name, dir: torrent.downloadDir, store: store)) {
//            store.storedThumbnails[torrent.id] = StoredThumbnail(id: torrent.id, url: url)
//        }
//    }
//    
//    private func scheduleRetry() {
//        guard retryAttempt < maxRetries else { return }
//        
//        retryAttempt += 1
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
//            checkThumbnail()
//        }
//    }
//    
//    private func isImage(url: URL) -> Bool {
//        imageExtensions.contains(url.pathExtension.lowercased())
//    }
//    
//    private func isVideo(url: URL) -> Bool {
//        videoExtensions.contains(url.pathExtension.lowercased())
//    }
//    
//    private func buildURL(for fileName: String, dir: String, store: Store) -> String {
//        guard let baseURL = config.url else { return "" }
//        return baseURL.appendingPathComponent(dir).appendingPathComponent(fileName).absoluteString
//    }
//}
//
//#endif
