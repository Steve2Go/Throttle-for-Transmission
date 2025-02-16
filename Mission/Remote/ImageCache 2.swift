//#if os(iOS)
//import UIKit
//#elseif os(macOS)
//import AppKit
//#endif
//import SwiftUI
//import AVFoundation
//import CryptoKit
//
//// MARK: - CryptoKit SHA-256 Helper
//
//extension String {
//    var sha256: String {
//        let data = Data(self.utf8)
//        let hash = SHA256.hash(data: data)
//        return hash.map { String(format: "%02x", $0) }.joined()
//    }
//}
//
//// MARK: - Platform Agnostic Image Type
//
//#if os(iOS)
//typealias PlatformImage = UIImage
//#elseif os(macOS)
//typealias PlatformImage = NSImage
//#endif
//
//// MARK: - Image Extensions for Cross-Platform Compatibility
//
//extension PlatformImage {
//    #if os(macOS)
//    var cgImage: CGImage? {
//        var rect = CGRect(origin: .zero, size: size)
//        return cgImage(forProposedRect: &rect, context: nil, hints: nil)
//    }
//    
////    convenience init?(data: Data) {
////        self.init(data: data)
////    }
//    
//    func pngData() -> Data? {
//        guard let cgImage = cgImage else { return nil }
//        let rep = NSBitmapImageRep(cgImage: cgImage)
//        return rep.representation(using: .png, properties: [:])
//    }
//    #endif
//    
//    func resized(to size: CGSize) -> PlatformImage? {
//        #if os(iOS)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { _ in
//            self.draw(in: CGRect(origin: .zero, size: size))
//        }
//        #elseif os(macOS)
//        let newImage = NSImage(size: size)
//        newImage.lockFocus()
//        self.draw(in: CGRect(origin: .zero, size: size))
//        newImage.unlockFocus()
//        return newImage
//        #endif
//    }
//    
//    func aspectFitResized(to targetSize: CGSize) -> PlatformImage? {
//        let aspectRatio = size.width / size.height
//        let newSize: CGSize
//        
//        if aspectRatio > 1 {
//            newSize = CGSize(width: targetSize.width,
//                           height: targetSize.width / aspectRatio)
//        } else {
//            newSize = CGSize(width: targetSize.height * aspectRatio,
//                           height: targetSize.height)
//        }
//        
//        return resized(to: newSize)
//    }
//}
//
//// MARK: - Disk Cache Helpers
//
//private func getCacheDirectory() -> URL {
//    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//    return cachesDirectory.appendingPathComponent("CachedImages")
//}
//
//private func getDiskCacheURL(for url: URL) -> URL {
//    let fileName = url.absoluteString.sha256
//    return getCacheDirectory().appendingPathComponent(fileName)
//}
//
//private func loadDiskCachedImage(for url: URL) -> PlatformImage? {
//    let fileURL = getDiskCacheURL(for: url)
//    let fm = FileManager.default
//    guard fm.fileExists(atPath: fileURL.path) else { return nil }
//    
//    if let attributes = try? fm.attributesOfItem(atPath: fileURL.path),
//       let modificationDate = attributes[.modificationDate] as? Date {
//        let tenDays: TimeInterval = 10 * 24 * 3600
//        if Date().timeIntervalSince(modificationDate) > tenDays {
//            try? fm.removeItem(at: fileURL)
//            return nil
//        } else {
//            try? fm.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
//        }
//    }
//    
//    if let data = try? Data(contentsOf: fileURL),
//       let image = PlatformImage(data: data) {
//        return image
//    }
//    return nil
//}
//
//private func storeDiskCachedImage(image: PlatformImage, for url: URL) {
//    let fileURL = getDiskCacheURL(for: url)
//    let directory = fileURL.deletingLastPathComponent()
//    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
//    if let data = image.pngData() {
//        try? data.write(to: fileURL)
//    }
//}
//
//// MARK: - In-Memory Cache
//
//private let cachedImageCache = NSCache<NSString, PlatformImage>()
//private let cachedVideoThumbCache = NSCache<NSString, PlatformImage>()
//
///// Generates (and caches) a thumbnail for a video at the specified URL using AVAssetImageGenerator
///// with a custom resource loader that uses NetworkManager.shared.session.
//func loadCachedVideoThumbnailForVideoAsset(from url: URL, completion: @escaping (PlatformImage?) -> Void) {
//    let cacheKey = ("video_thumb_" + url.absoluteString) as NSString
//    
//    // Check in-memory cache first
//    if let cachedImage = cachedVideoThumbCache.object(forKey: cacheKey) {
//        DispatchQueue.main.async { completion(cachedImage) }
//        return
//    }
//    
//    // Check disk cache
//    if let diskCachedImage = loadDiskCachedImage(for: url) {
//        let size = estimateImageSize(diskCachedImage)
//        cachedVideoThumbCache.setObject(diskCachedImage, forKey: cacheKey, withApproximateSize: size)
//        DispatchQueue.main.async { completion(diskCachedImage) }
//        return
//    }
//    
//    // Generate thumbnail if not cached
//    let resourceLoaderDelegate = CustomResourceLoaderDelegate(session: NetworkManager.shared.session)
//    let asset = AVURLAsset(url: url)
//    asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
//    
//    let imageGenerator = AVAssetImageGenerator(asset: asset)
//    imageGenerator.appliesPreferredTrackTransform = true
//    let time = CMTime(seconds: 1, preferredTimescale: 600)
//    
//    imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { requestedTime, cgImage, actualTime, result, error in
//        if let cgImage = cgImage {
//            #if os(iOS)
//            let originalImage = UIImage(cgImage: cgImage)
//            #elseif os(macOS)
//            let originalImage = NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
//            #endif
//            
//            // Resize thumbnail to 100x100
//            let resizedImage = originalImage.aspectFitResized(to: CGSize(width: 100, height: 100))
//            guard let finalImage = resizedImage else {
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//            
//            let size = estimateImageSize(finalImage)
//            cachedVideoThumbCache.setObject(finalImage, forKey: cacheKey, withApproximateSize: size)
//            storeDiskCachedImage(image: finalImage, for: url)
//            DispatchQueue.main.async { completion(finalImage) }
//        } else {
//            DispatchQueue.main.async { completion(nil) }
//        }
//    }
//}
//
//// MARK: - Custom Resource Loader Delegate for Video Assets
//class CustomResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
//    let session: URLSession
//    
//    init(session: URLSession) {
//        self.session = session
//        super.init()
//    }
//    
//    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
//                       shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
//        guard let url = loadingRequest.request.url else {
//            loadingRequest.finishLoading(with: NSError(domain: "CustomResourceLoader", code: -1, userInfo: nil))
//            return false
//        }
//        
//        let task = session.dataTask(with: url) { data, response, error in
//            if let error = error {
//                loadingRequest.finishLoading(with: error)
//                return
//            }
//            if let data = data {
//                loadingRequest.dataRequest?.respond(with: data)
//                loadingRequest.finishLoading()
//            } else {
//                loadingRequest.finishLoading(with: NSError(domain: "CustomResourceLoader", code: -2, userInfo: nil))
//            }
//        }
//        task.resume()
//        return true
//    }
//}
//
///// Clears the in-memory video thumbnail cache
//func clearCachedVideoThumbnails() {
//    cachedVideoThumbCache.removeAllObjects()
//}
//
//func loadCachedImage(from url: URL, completion: @escaping (PlatformImage?) -> Void) {
//    let cacheKey = url.absoluteString as NSString
//    
//    if let cachedImage = cachedImageCache.object(forKey: cacheKey) {
//        DispatchQueue.main.async { completion(cachedImage) }
//        return
//    }
//    
//    if let diskImage = loadDiskCachedImage(for: url) {
//        let size = estimateImageSize(diskImage)
//        cachedImageCache.setObject(diskImage, forKey: cacheKey, withApproximateSize: size)
//        DispatchQueue.main.async { completion(diskImage) }
//        return
//    }
//    
//    let task = NetworkManager.shared.session.dataTask(with: url) { data, response, error in
//        if let data = data, let downloadedImage = PlatformImage(data: data) {
//            let size = estimateImageSize(downloadedImage)
//            cachedImageCache.setObject(downloadedImage, forKey: cacheKey, withApproximateSize: size)
//            storeDiskCachedImage(image: downloadedImage, for: url)
//            DispatchQueue.main.async { completion(downloadedImage) }
//        } else {
//            DispatchQueue.main.async { completion(nil) }
//        }
//    }
//    task.resume()
//}
//
//// MARK: - SwiftUI Views
//
//struct CachedImage<Placeholder: View>: View {
//    let url: URL
//    var placeholder: () -> Placeholder
//    var resizableEnabled: Bool = false
//    
//    @State private var loadedImage: PlatformImage? = nil
//    
//    init(_ url: URL, @ViewBuilder placeholder: @escaping () -> Placeholder) {
//        self.url = url
//        self.placeholder = placeholder
//    }
//    
//    var body: some View {
//        Group {
//            if let image = loadedImage {
//                #if os(iOS)
//                let img = Image(uiImage: image)
//                #elseif os(macOS)
//                let img = Image(nsImage: image)
//                #endif
//                if resizableEnabled { img.resizable() } else { img }
//            } else {
//                placeholder()
//            }
//        }
//        .onAppear {
//            loadCachedImage(from: url) { image in
//                self.loadedImage = image
//            }
//        }
//    }
//    
//    func resizable() -> CachedImage {
//        var copy = self
//        copy.resizableEnabled = true
//        return copy
//    }
//}
//
//// MARK: - Video Thumbnail Support
//
//struct CachedVideoThumbnail<Placeholder: View>: View {
//    let url: URL
//    var placeholder: () -> Placeholder
//    var resizableEnabled: Bool = false
//    
//    @State private var thumbnail: PlatformImage? = nil
//    
//    init(_ url: URL, @ViewBuilder placeholder: @escaping () -> Placeholder) {
//        self.url = url
//        self.placeholder = placeholder
//    }
//    
//    var body: some View {
//        Group {
//            if let image = thumbnail {
//                #if os(iOS)
//                let img = Image(uiImage: image)
//                #elseif os(macOS)
//                let img = Image(nsImage: image)
//                #endif
//                if resizableEnabled { img.resizable() } else { img }
//            } else {
//                placeholder()
//            }
//        }
//        .onAppear {
//            loadCachedVideoThumbnailForVideoAsset(from: url) { image in
//                self.thumbnail = image
//            }
//        }
//    }
//    
//    func resizable() -> CachedVideoThumbnail {
//        var copy = self
//        copy.resizableEnabled = true
//        return copy
//    }
//}
//
//// MARK: - Thumbnail View Components
//
//struct ImageThumbnailView: View {
//    let imageURL: URL?
//    
//    var body: some View {
//        if let url = imageURL {
//            CachedImage(url) {
//                Image(systemName: "camera.circle")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(.gray)
//                    .padding(10)
//            }
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 50, height: 50)
//            .cornerRadius(10)
//            .clipped()
//            .padding(10)
//        }
//    }
//}
//
//struct VideoThumbnailView: View {
//    let videoURL: URL?
//    
//    var body: some View {
//        if let url = videoURL {
//            CachedVideoThumbnail(url) {
//                Image(systemName: "play.circle")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)
//                    .foregroundColor(.gray)
//                    .padding(10)
//            }
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 50, height: 50)
//            .cornerRadius(10)
//            .clipped()
//            .padding(10)
//        }
//    }
//}
//
//// MARK: - Zoomable Container
//
//fileprivate let maxAllowedScale = 4.0
//
//struct ZoomableContainer<Content: View>: View {
//    let content: Content
//    
//    @State private var currentScale: CGFloat = 1.0
//    @State private var tapLocation: CGPoint = .zero
//    
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    func doubleTapAction(location: CGPoint) {
//        tapLocation = location
//        currentScale = currentScale == 1.0 ? maxAllowedScale : 1.0
//    }
//    
//    var body: some View {
//        #if os(iOS)
//        ZoomableScrollView(scale: $currentScale, tapLocation: $tapLocation) {
//            content
//        }
//        .onTapGesture(count: 2, perform: doubleTapAction)
//        #elseif os(macOS)
//        ZoomableNSScrollView(scale: $currentScale, tapLocation: $tapLocation) {
//            content
//        }
//        .onTapGesture(count: 2, perform: doubleTapAction)
//        #endif
//    }
//    
//    #if os(iOS)
//    fileprivate struct ZoomableScrollView<Content: View>: UIViewRepresentable {
//        private var content: Content
//        @Binding private var currentScale: CGFloat
//        @Binding private var tapLocation: CGPoint
//        
//        init(scale: Binding<CGFloat>, tapLocation: Binding<CGPoint>, @ViewBuilder content: () -> Content) {
//            _currentScale = scale
//            _tapLocation = tapLocation
//            self.content = content()
//        }
//        
//        func makeUIView(context: Context) -> UIScrollView {
//            let scrollView = UIScrollView()
//            scrollView.delegate = context.coordinator
//            scrollView.maximumZoomScale = maxAllowedScale
//            scrollView.minimumZoomScale = 1
//            scrollView.bouncesZoom = true
//            scrollView.showsHorizontalScrollIndicator = false
//            scrollView.showsVerticalScrollIndicator = false
//            scrollView.clipsToBounds = false
//            scrollView.backgroundColor = .black
//            
//            let hostedView = context.coordinator.hostingController.view!
//            hostedView.translatesAutoresizingMaskIntoConstraints = true
//            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            hostedView.frame = scrollView.bounds
//            hostedView.backgroundColor = .black
//            scrollView.addSubview(hostedView)
//            
//            return scrollView
//        }
//        
//        func makeCoordinator() -> Coordinator {
//            return Coordinator(hostingController: UIHostingController(rootView: content), scale: $currentScale)
//        }
//        
//        func updateUIView(_ uiView: UIScrollView, context: Context) {
//            context.coordinator.hostingController.rootView = content
//            
//            if uiView.zoomScale > uiView.minimumZoomScale {
//                uiView.setZoomScale(currentScale, animated: true)
//            } else if tapLocation != .zero {
//                uiView.zoom(to: zoomRect(for: uiView, scale: uiView.maximumZoomScale, center: tapLocation), animated: true)
//                DispatchQueue.main.async { tapLocation = .zero }
//            }
//        }
//        
//        func zoomRect(for scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
//            let scrollViewSize = scrollView.bounds.size
//            
//            let width = scrollViewSize.width / scale
//            let height = scrollViewSize.height / scale
//            let x = center.x - (width / 2.0)
//            let y = center.y - (height / 2.0)
//            
//            return CGRect(x: x, y: y, width: width, height: height)
//        }
//        
//        class Coordinator: NSObject, UIScrollViewDelegate {
//            var hostingController: UIHostingController<Content>
//            @Binding var currentScale: CGFloat
//            
//            init(hostingController: UIHostingController<Content>, scale: Binding<CGFloat>) {
//                self.hostingController = hostingController
//                _currentScale = scale
//            }
//            
//            func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//                return hostingController.view
//            }
//            
//            func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//                currentScale = scale
//            }
//        }
//    }
//    #elseif os(macOS)
//    fileprivate struct ZoomableNSScrollView<Content: View>: NSViewRepresentable {
//        private var content: Content
//        @Binding private var currentScale: CGFloat
//        @Binding private var tapLocation: CGPoint
//        
//        init(scale: Binding<CGFloat>, tapLocation: Binding<CGPoint>, @ViewBuilder content: () -> Content) {
//            _currentScale = scale
//            _tapLocation = tapLocation
//            self.content = content()
//        }
//        
//        func makeNSView(context: Context) -> NSScrollView {
//            let scrollView = NSScrollView()
//            scrollView.hasVerticalScroller = true
//            scrollView.hasHorizontalScroller = true
//            scrollView.autohidesScrollers = true
//            scrollView.allowsMagnification = true
//            scrollView.maxMagnification = maxAllowedScale
//            scrollView.minMagnification = 1.0
//            
//            let hostedView = NSHostingView(rootView: content)
//            hostedView.frame = scrollView.bounds
//            hostedView.autoresizingMask = [.width, .height]
//            
//            scrollView.documentView = hostedView
//            return scrollView
//        }
//        
//        func updateNSView(_ nsView: NSScrollView, context: Context) {
//            if let hostedView = nsView.documentView as? NSHostingView<Content> {
//                hostedView.rootView = content
//            }
//            
//            if currentScale != nsView.magnification {
//                nsView.magnification = currentScale
//            }
//            
//            if tapLocation != .zero {
//                let point = CGPoint(
//                    x: tapLocation.x - nsView.documentVisibleRect.width / 2,
//                    y: tapLocation.y - nsView.documentVisibleRect.height / 2
//                )
//                nsView.scroll(point)
//                DispatchQueue.main.async { tapLocation = .zero }
//            }
//        }
//    }
//    #endif
//}
//
//func clearAllCaches() {
//    // Clear in-memory caches
//    cachedImageCache.removeAllObjects()
//    cachedVideoThumbCache.removeAllObjects()
//    
//    // Clear disk cache
//    let cacheDirectory = getCacheDirectory()
//    try? FileManager.default.removeItem(at: cacheDirectory)
//    try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
//}
//
//// MARK: - Cache Configuration
//
//private struct CacheConfig {
//    static let defaultMaxMemoryLimit: Int = 100 * 1024 * 1024  // 100 MB
//    static let prunePercentage: Float = 0.5  // Remove 50% when limit is reached
//}
//
//// MARK: - Cache Management
//
//#if os(iOS)
//import UIKit
//#elseif os(macOS)
//import AppKit
//#endif
//
//class CacheManager {
//    static let shared = CacheManager()
//    
//    // Track approximate memory usage
//    private var imageCacheSize: Int = 0
//    private var videoCacheSize: Int = 0
//    private let cacheSizeLock = NSLock()
//    
//    private init() {
//        setupCacheLimits()
//        setupMemoryPressureMonitoring()
//        setupCacheObservation()
//    }
//    
//    private func setupCacheLimits() {
//        // Set count limits as a safeguard
//        cachedImageCache.countLimit = 500
//        cachedVideoThumbCache.countLimit = 200
//    }
//    
//    private func setupCacheObservation() {
//        // Observe when objects are added to caches
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleImageAdded(_:)),
//            name: .init("ImageCacheObjectAdded"),
//            object: nil
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleVideoThumbnailAdded(_:)),
//            name: .init("VideoThumbnailCacheObjectAdded"),
//            object: nil
//        )
//    }
//    
//    private func setupMemoryPressureMonitoring() {
//        #if os(iOS)
//        // iOS memory warning notification
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleMemoryPressure),
//            name: UIApplication.didReceiveMemoryWarningNotification,
//            object: nil
//        )
//        
//        // Background notification
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleEnterBackground),
//            name: UIApplication.didEnterBackgroundNotification,
//            object: nil
//        )
//        #elseif os(macOS)
//        // macOS memory pressure monitoring
//        DispatchQueue.main.async {
//            let center = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])
//            center.setEventHandler { [weak self] in
//                self?.handleMemoryPressure()
//            }
//            center.resume()
//        }
//        #endif
//    }
//    
//    @objc private func handleMemoryPressure() {
//        pruneMemoryCache(aggressive: true)
//    }
//    
//    #if os(iOS)
//    @objc private func handleEnterBackground() {
//        pruneMemoryCache(aggressive: false)
//    }
//    #endif
//    
//    @objc private func handleImageAdded(_ notification: Notification) {
//        if let size = notification.userInfo?["size"] as? Int {
//            cacheSizeLock.lock()
//            imageCacheSize += size
//            if imageCacheSize > CacheConfig.defaultMaxMemoryLimit {
//                pruneMemoryCache()
//            }
//            cacheSizeLock.unlock()
//        }
//    }
//    
//    @objc private func handleVideoThumbnailAdded(_ notification: Notification) {
//        if let size = notification.userInfo?["size"] as? Int {
//            cacheSizeLock.lock()
//            videoCacheSize += size
//            if videoCacheSize > CacheConfig.defaultMaxMemoryLimit {
//                pruneMemoryCache()
//            }
//            cacheSizeLock.unlock()
//        }
//    }
//    
//    /// Prunes the memory cache based on current usage
//    /// - Parameter aggressive: If true, clears more aggressively (used for memory warnings)
//    func pruneMemoryCache(aggressive: Bool = false) {
//        let prunePercentage = aggressive ? 0.75 : CacheConfig.prunePercentage
//        
//        cacheSizeLock.lock()
//        defer { cacheSizeLock.unlock() }
//        
//        // If either cache exceeds limit, reduce it
//        if imageCacheSize > CacheConfig.defaultMaxMemoryLimit {
//            cachedImageCache.removeAllObjects()
//            imageCacheSize = 0
//        }
//        
//        if videoCacheSize > CacheConfig.defaultMaxMemoryLimit {
//            cachedVideoThumbCache.removeAllObjects()
//            videoCacheSize = 0
//        }
//        
//        // On aggressive clear, also trigger disk cache cleanup
//        if aggressive {
//            cleanupDiskCache()
//        }
//    }
//    
//    private func cleanupDiskCache() {
//        DispatchQueue.global(qos: .background).async {
//            let fileManager = FileManager.default
//            let cacheDirectory = getCacheDirectory()
//            
//            guard let contents = try? fileManager.contentsOfDirectory(
//                at: cacheDirectory,
//                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey]
//            ) else { return }
//            
//            // Remove files older than 7 days
//            let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
//            
//            for url in contents {
//                guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
//                      let creationDate = attributes[.creationDate] as? Date,
//                      creationDate < sevenDaysAgo else { continue }
//                
//                try? fileManager.removeItem(at: url)
//            }
//        }
//    }
//}
//
//// MARK: - Cache Extensions for Size Tracking
//
//extension NSCache {
//    @objc func setObject(_ obj: ObjectType, forKey key: KeyType, withApproximateSize size: Int) {
//        setObject(obj, forKey: key)
//        NotificationCenter.default.post(
//            name: .init("ImageCacheObjectAdded"),
//            object: nil,
//            userInfo: ["size": size]
//        )
//    }
//}
//
//// MARK: - Helper Functions for Image Size Estimation
//
//func estimateImageSize(_ image: PlatformImage) -> Int {
//    #if os(iOS)
//    if let cgImage = image.cgImage {
//        return cgImage.bytesPerRow * cgImage.height
//    }
//    return 0
//    #elseif os(macOS)
//    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
//        return cgImage.bytesPerRow * cgImage.height
//    }
//    return 0
//    #endif
//}
//
//// MARK: - Public Interface
//
//func initializeCacheManagement() {
//    _ = CacheManager.shared
//}
