import SwiftUI
import Foundation
import KeychainAccess
import UniformTypeIdentifiers
import SwiftyJSON

struct Server {
    var config: TransmissionConfig
    var auth: TransmissionAuth
}

class Store: NSObject, ObservableObject {
    @Published var torrents: [Torrent] = []
    @Published var setup: Bool = false
    @Published var server: Server?
    @Published var host: Host?
    @Published var path: Path?
    @Published var hostName: String?
    @Published var pathMap: [String] = []
    @Published var PmapKey = ""
    
    @Published var uploadWaiting: Bool = false
    @Published var isFileWaiting: Bool = false
    @Published var urlWaiting: String = ""
    
    @Published var isShowingLoading: Bool = false
    @Published var defaultDownloadDir: String = ""
    
    @Published var isShowingAddAlert: Bool = false
    @Published var isShowingLocation: Bool = false
    @Published var isShowingTorrentInfoDialog: Bool = false
    @Published var isShowingTorrentInfoDialogUpdate: Bool = false
    @Published var isShowingServerAlert: Bool = false
    @Published var isShowingTransferFiles: Bool = false
    @Published var isShowingSettings: Bool = false
    
    @Published var transferToSetFiles: Int = 0
    @Published var editServers: Bool = false
    @Published var successToast: Bool = false
    @Published var hasUpdate: Bool = false
    @Published var latestRelease: String = ""
    @Published var latestRelTitle: String = ""
    @Published var latestChangelog: String = ""
    
    @Published var isError: Bool = false
    @Published var debugBrief: String = ""
    @Published var debugMessage: String = ""
    @Published var tabName: String = "Mission"
    
    @Published var downloadDir: String = ""
    @Published var currentTorrentId: Int?
    @Published var currentTorrent: JSON?
    @Published var addTransferFilesList: [File] = []
    @Published var addTransferFilesInfo: [File] = []
    @Published var fileSelections: [Int] = []
    @Published var color: [Color] = [Color.red, Color.orange, Color.yellow, Color.teal, Color.blue, Color.yellow, Color.green ]
    @Published var status: [String] = ["Stopped", "Waiting to Check", "Checking...", "Waiting to Download", "Downloading", "Waiting to Seed", "Seeding" ]
    
    var timer: Timer = Timer()
    
    public func setHost(host: Host) {
        var config = TransmissionConfig()
        config.host = host.server
        config.port = Int(host.port)
        config.path = host.path ?? "/transmission/rpc/"
        self.PmapKey = host.name! + "Pmap"
        self.tabName = host.name ?? "Mission"
        var pmap = (UserDefaults.standard.string(forKey: (self.PmapKey)) ?? "")
        self.pathMap = pmap.components(separatedBy: "=")
        UserDefaults.standard.setValue(host.name, forKey: "lastServer")
        
        
        let auth = TransmissionAuth(username: host.username!, password: readPassword(name: host.name!))
        self.server = Server(config: config, auth: auth)
        self.host = host
        self.hostName = host.name
    }
    public func testPathmap() -> Bool {
        if UserDefaults.stringexists(key: self.PmapKey){
            if !self.pathMap[0].isEmpty {
                if directoryExistsAtPath(self.pathMap[1]){
                    return true
                }
                return false
            }
            return false
        }
        return false
    }
    
    func readPassword(name: String) -> String {
        let keychain = Keychain(service: "me.jdiggity.mission")
        let password = keychain[name]
        return password!
    }
    


    func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            
            DispatchQueue.main.async {
                updateList(store: self, update: { vals in
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                        self.torrents = vals
                        if self.isShowingTorrentInfoDialog == true {
                            let info = makeConfig(store: self)
                            self.showTorrentInfo(transferId: self.currentTorrentId!, info: info)
                            self.isShowingTorrentInfoDialogUpdate.toggle()
                        }
                    }
                })
            }
        })
    }
    
    func showTorrentInfo(transferId: Int, info: (config: TransmissionConfig, auth: TransmissionAuth)) {
        getTransferInfo(transferId: transferId, info: info, onReceived: { f in
            DispatchQueue.main.async {
                self.currentTorrent = JSON(f)
                self.currentTorrentId = transferId
                if self.isShowingTorrentInfoDialog == false {
                    self.isShowingTorrentInfoDialog.toggle()
                }
            }
            })
        }
    }

//extension UTType {
//    static var torrent: UTType {
//        UTType.types(tag: "torrent", tagClass: .filenameExtension, conformingTo: nil).first!
//    }
//}


