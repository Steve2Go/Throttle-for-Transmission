import Foundation
import SwiftUI
import UniformTypeIdentifiers

public struct AddTorrentDialog: View {
    //@ObservedObject var store: Store
    @ObservedObject var store: Store = Store()
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var hosts: FetchedResults<Host>
    
    @State var alertInput: String = ""
    @State var downloadDir: String = ""
    @State var selectedServer: String = ""
    @State private var showFileImporter = false
    @State private var showingAlert = false
    
    public var body: some View {
        
        VStack {
            HStack {
                
                
                Text("Add Torrent")
                    .font(.headline)
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                Button(action: {
                    store.isShowingAddAlert.toggle()
                    store.urlWaiting = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                        .frame(alignment: .trailing)
                }).buttonStyle(BorderlessButtonStyle())
            }
            
            Text("Add either a magnet link or .torrent file.")
                .fixedSize(horizontal: true, vertical: true)
                .font(.body)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Server")
                    .font(.system(size: 10))
                    .padding(.top, 10)
                    .padding(.leading)
                    .padding(.bottom, 5)
                Menu(selectedServer) {
                    ForEach(hosts, id: \.self) { host in
                        Button(action: {
                            store.setHost(host: host)
                            selectedServer = host.name!
                            let info = makeConfig(store: store)
                            getDefaultDownloadDir(config: info.config, auth: info.auth, onResponse: { downloadDi in
                                // DispatchQueue.main.async {
                                //UserDefaults.standard.setValue(downloadDir, forKey: "downloadDir")
                                downloadDir = downloadDi
                                // }
                            })
                            //downloadDir = store.defaultDownloadDir
                            //downloadDir = "Fetching..."
                            //                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Change `2.0` to the desired number of seconds.
                            //                               // Code you want to be delayed
                            //                                downloadDir = store.defaultDownloadDir
                            //                            }
                            
                            store.startTimer()
                            store.isShowingLoading.toggle()
                        }) {
                            let text = host.name
                            Text(text!)
                        }
                    }
                }.padding([.leading, .trailing])
                
                Text("Magnet Link or File Path")
                    .font(.system(size: 10))
                    .padding(.top, 10)
                    .padding(.leading)
                    .padding(.bottom, 5)
                
                TextField(
                    "Magnet link or File Upload Path",
                    text: $alertInput
                ).onSubmit {
                    // TODO: Validate entry
                }
                .padding([.leading, .trailing])
            }
            .padding(.bottom, 5)
            
            VStack (alignment: .leading, spacing: 0){
                Text("Download Destination")
                    .font(.system(size: 10))
                    .padding(.top, 10)
                    .padding(.leading)
                    .padding(.bottom, 5)
                HStack {
                    TextField(
                        "Download Destination",
                        text: $downloadDir
                    )
                    .padding([.leading])
                    if store.testPathmap(){
                        Button("..."){
                            showFileImporter = true
                            
                        } .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.directory], onCompletion: { result in
                            switch result {
                            case .success(let file):
                                let str = file.absoluteString
                                if let range = str.range(of: "file://" + store.pathMap[1]) {
                                    downloadDir = str.replacingCharacters(in: range, with:store.pathMap[0])
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                                //                        }
                                //                    if (result != nil) {
                                //                        let str = result.
                                //                                                if let range = str.range(of: store.pathMap[1]) {
                                //                                                    downloadDir = str.replacingCharacters(in: range, with:store.pathMap[0])
                                //                                                 }
                                
                                //downloadDir = result!.path.replacingOccurrences(of: store.pathMap[1], with: store.pathMap[0])
                                
                                // path contains the directory path e.g
                                // /Users/ourcodeworld/Desktop/folder
                                //                                            }
                            }
                        }).fileDialogDefaultDirectory(URL(fileURLWithPath: "file://" + downloadDir))
                    }
                }}
            
            HStack {
                Button("Upload file") {
                    // Show file chooser panel
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.allowedContentTypes = [.torrent]
                    
                    if panel.runModal() == .OK {
                        alertInput = panel.url!.absoluteString
//                        // Convert the file to a base64 string
//                        let fileData = try! Data.init(contentsOf: panel.url!)
//                        let fileStream: String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
//                        
//                        let info = makeConfig(store: store)
//                        
//                        addTorrent(fileUrl: fileStream, saveLocation: downloadDir, auth: info.auth, file: true, config: info.config, onAdd: { response in
//                            if response.response == TransmissionResponse.success {
//                                store.isShowingAddAlert.toggle()
//                                //showFilePicker(transferId: response.transferId, info: info)
//                            }
//                        })
                    }
                }
                .padding()
                Spacer()
                Button("Submit") {
                    // Send the magnet link to the server
                    if alertInput.hasPrefix("file:///") {
                        let fileUrl = URL(string: alertInput)!
                        let fileData = try! Data.init(contentsOf: fileUrl)
                        let fileStream: String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
                        
                        let info = makeConfig(store: store)
                        
                        addTorrent(fileUrl: fileStream, saveLocation: downloadDir, auth: info.auth, file: true, config: info.config, onAdd: { response in
                            if response.response == TransmissionResponse.success {
                                
                                /// Delete the file
                                if UserDefaults.standard.bool(forKey: "deleteFile") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        // your function
                                        
                                        let fileURL = URL(string: alertInput)
                                        let fileManager = FileManager.default
                                        
                                        do {
                                            try fileManager.removeItem(at: fileURL!)
                                            print("File Removed")
                                        } catch {
                                            print("Error: \(error)")
                                        }}
                                }
                                ///Hide Window
                                store.isShowingAddAlert.toggle()
                                if UserDefaults.standard.bool(forKey: "chooseeFiles") == true{
                                    if alertInput.hasPrefix("file:/"){
                                        showFilePicker(transferId: response.transferId, info: info)
                                    }
                                }
                                //showFilePicker(transferId: response.transferId, info: info)
                                
                            } else{
                                showingAlert = true
                            }
                        })
                        
                    } else {
                        
                        let info = makeConfig(store: store)
                        addTorrent(fileUrl: alertInput, saveLocation: downloadDir, auth: info.auth, file: false, config: info.config, onAdd: { response in
                            if response.response == TransmissionResponse.success {
                                store.isShowingAddAlert.toggle()
                            }else{
                                showingAlert = true
                            }
                        })
                    }
                }.padding()
                    .alert("Adding Failed.", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                    }message: {
                        Text("The most comon causes of this error are trying to add a duplicate Torrent, or communication errors.")
                    }
            }
            
        }.interactiveDismissDisabled(false)
            .onAppear {
                DispatchQueue.main.async {
                    let info = makeConfig(store: store)
                    getDefaultDownloadDir(config: info.config, auth: info.auth, onResponse: { downloadDi in
                        // DispatchQueue.main.async {
                        //UserDefaults.standard.setValue(downloadDir, forKey: "downloadDir")
                        downloadDir = downloadDi
                        // }
                    })
                    alertInput = store.urlWaiting
                    selectedServer = store.hostName!  //UserDefaults.standard.string(forKey: "currentHost")!
                }
            }
            
      
    }
    func showFilePicker(transferId: Int, info: (config: TransmissionConfig, auth: TransmissionAuth)) {
        DispatchQueue.main.async {
            store.transferToSetFiles = transferId
            store.isShowingTorrentInfoDialog = false
            store.isShowingAddAlert = false
            store.isShowingTransferFiles.toggle()
        }
    }
}

// This is needed to silence buildtime warnings related to the filepicker.
// `.allowedFileTypes` was deprecated in favor of this attrocity. No comment <3
extension UTType {
    static var torrent: UTType {
        UTType.types(tag: "torrent", tagClass: .filenameExtension, conformingTo: nil).first!
    }
}
