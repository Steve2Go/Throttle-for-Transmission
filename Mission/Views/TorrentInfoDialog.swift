//
//  TorrentInfoFrame.swift
//  Mission
//
//  Created by Stephen Grigg on 4/1/2025.
//

import SwiftUI
import SwiftyJSON
import UniformTypeIdentifiers

struct Trackers: Identifiable{
    let id = UUID()
    let sitename: String
    let announce: String
}

struct TorrentInfoDialog: View {

    @ObservedObject var store: Store
    @State var torrent : JSON?
    @State var torrentId : Int?
    @State var tempTorrent: Torrent?
    @State var deleteDialog: Bool = false
    @State var magnetLink : String = ""
    @State var statusList : [String] = ["Stopped","Queued to Verify" , "Verifying...", "Queued" , "Downloading", "In Seed Queue", "Seeding"]
    @State var percentComplete: Double = 0
    @State var data : [String] = []
    @State var tData : [String] = []
    @State var trackerTable = [Trackers(sitename: "Loading..",
                                    announce: "Loading...")]

        let columns = [
            GridItem(.adaptive(minimum: 80))
        ]

    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
          //  HStack {
            HStack{
                Button ("Select", systemImage: "filemenu.and.selection", action: {
                    let info = makeConfig(store: store)
                    showFilePicker(transferId: torrentId!, info: info)
                })
                Button ("Move" , systemImage: "filemenu.and.cursorarrow"){
                    //let info = makeConfig(store: store)
                    DispatchQueue.main.async {
                        store.isShowingTorrentInfoDialog.toggle()
                        store.isShowingLocation.toggle()
                    }
                }

                Button ("Announce", systemImage: "megaphone"){
                    let info = makeConfig(store: store)
                    requestForTorrent(torrent: tempTorrent!, method: "torrent-announce", config: info.config, auth: info.auth, onUpd: { response in
                        // TODO: Handle response
                    })
                }
                
                Button ("Verify" , systemImage: "externaldrive.badge.checkmark"){
                    let info = makeConfig(store: store)
                    requestForTorrent(torrent: tempTorrent!, method: "torrent-verify", config: info.config, auth: info.auth, onUpd: { response in
                        // TODO: Handle response
                    })
                }
                Button ("Delete" , systemImage: "x.circle"){
                    deleteDialog.toggle()
                }
                if store.testPathmap(){
                    Button ( "Open in Finder", systemImage: "externaldrive") {
                        let str = torrent!["downloadDir"].stringValue + "/" + torrent!["name"].stringValue
                        
                        if let range = str.range(of: store.pathMap[0]) {
                            let path = str.replacingCharacters(in: range, with:store.pathMap[1])
                            NSWorkspace.shared.activateFileViewerSelecting([URL(filePath: path)])
                        }
                    }
                }
                Spacer()
                Button(action: {
                    store.isShowingTorrentInfoDialog.toggle()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                }).buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 10)
                        .padding(.bottom, 0)
               
                
            }
            
//            HStack {
//
//                 Spacer()
//                Button(action: {
//                    store.isShowingTorrentInfoDialog.toggle()
//                }, label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .padding(.top, 10)
//                        .padding(.bottom, 0)
//                }).buttonStyle(BorderlessButtonStyle())
//                        .padding(.trailing, 10)
//                        .padding(.bottom, 0)
//              }
            
                Text(torrent?["name"].string ?? "...")
                .font(.headline)
                .padding(.leading, 10)
                .padding(.bottom, 10)
                .padding(.top, 0)

                
//
////                        TableColumn("joined at") { customer in
////                            Text(customer.creationDate, style: .date)
////                        }
//                    }
            ScrollView {
                let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ]
                LazyVGrid(columns: columns, alignment: .leading, spacing: 5 ) {
                                ForEach(data, id: \.self) { item in
                                    Text(item)
                                }
                            }
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: 310)
                    .multilineTextAlignment(.leading)
            ScrollView {
                let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                     
                    ]
                LazyVGrid(columns: columns, alignment: .leading, spacing: 5 ) {
                                ForEach(tData, id: \.self) { item in
                                    Text(item)
                                }
                            }
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                    .multilineTextAlignment(.leading)
            Table(trackerTable) {
                        TableColumn("Tracker", value: \.sitename)
                    .width(170)
                        TableColumn("Url", value: \.announce)
                    }
            TextField(
                "Magnet link",
                text: $magnetLink
                
            ).padding([.leading, .trailing]).padding(.bottom, 10)
                .padding(.top, 0)
//                .onTapGesture(count: 2) {
//                    copyToClipBoard(textToCopy: magnetLink)
//                    }
            //}

        }.frame(maxWidth: .infinity, alignment: .leading) //<-- Here
            .padding(12)
            .alert(
                "Remove Transfer",
                isPresented: $deleteDialog) {
                    Button(role: .destructive) {
                        let info = makeConfig(store: store)
                        store.isShowingTorrentInfoDialog.toggle()
                        deleteTorrent(torrent: tempTorrent!, erase: true, config: info.config, auth: info.auth, onDel: { response in
                            // TODO: Handle response
                        })
                        deleteDialog.toggle()
                    } label: {
                        Text("Delete files")
                    }
                    Button("Don't delete") {
                        store.isShowingTorrentInfoDialog.toggle()
                        let info = makeConfig(store: store)
                        deleteTorrent(torrent: tempTorrent!, erase: false, config: info.config, auth: info.auth, onDel: { response in
                            // TODO: Handle response
                        })
                        deleteDialog.toggle()
                    }
                } message: {
                    Text("Would you like to delete the transfered files from disk?")
                }.interactiveDismissDisabled(false)
            .task(id: store.isShowingTorrentInfoDialogUpdate) {
                        guard !store.isShowingTorrentInfoDialogUpdate else {return}
            torrent = JSON(store.currentTorrent)
                dump(torrent)
            torrentId = store.currentTorrentId
            magnetLink = torrent!["magnetLink"].string!
            
            percentComplete = (torrent!["percentComplete"].doubleValue * 100)
            ///Status and error are number codes
            var stat = torrent!["status"].intValue
            var status = statusList[stat]
                let lastactive = timestampToDate(stamp: torrent!["activityDate"].intValue)
        ////Todo - priorties for more than one file
            //let priority = torrent!["fileStats"]["priority"].stringValue
                trackerTable.removeAll()
                for tracker in torrent!["trackers"].arrayValue{
                    trackerTable.append(Trackers(sitename: tracker["sitename"].stringValue,
                                                announce: tracker["announce"].stringValue))
                }
                //trackerTable = trackerList
                let downloaded = ByteCountFormatter.string(fromByteCount: torrent!["downloadedEver"].int64Value, countStyle: .file)
                tempTorrent = Torrent(id: torrentId!, name: "", totalSize: 0, percentComplete: Double(signOf: 0,magnitudeOf: 0), status: 0, peersSendingToUs: 0, peersConnected: 0, addedDate: 0, activityDate: 0, downloadDir: "", recheckProgress: Double(signOf: 0,magnitudeOf: 0))
            ///Grid Values
                data = [ "Status: " + status ,
                        // "Downloaded: " + String(Int(percentComplete)) + "%" ,
                         "Error: " + torrent!["error"].stringValue,
                         "Remaining: " + ByteCountFormatter.string(fromByteCount: torrent!["leftUntilDone"].int64Value, countStyle: .file),
                         "Downloaded: " + ByteCountFormatter.string(fromByteCount: torrent!["downloadedEver"].int64Value, countStyle: .file),
                         "Uploaded: " + ByteCountFormatter.string(fromByteCount: torrent!["uploadedEver"].int64Value, countStyle: .file),
                         "Wasted: " + ByteCountFormatter.string(fromByteCount: torrent!["corruptEver"].int64Value, countStyle: .file),
                         "Download Speed: " + ByteCountFormatter.string(fromByteCount: torrent!["rateDownload"].int64Value, countStyle: .file) + "s",
                         "Upload Speed: " + ByteCountFormatter.string(fromByteCount: torrent!["rateUpload"].int64Value, countStyle: .file) + "s",
                         "Priority: " + torrent!["bandwidthPriority"].stringValue,
                         "Share Ratio: " + torrent!["uploadRatio"].stringValue,
                         "Down Limit: " + torrent!["downloadLimit"].stringValue,
                         "Up Limit: " + torrent!["uploadLimit"].stringValue,
                         "Seeds: " + torrent!["webseedsSendingToUs"].stringValue,
                         "Peers: " + torrent!["peersConnected"].stringValue,
                         "Max Peers: " + torrent!["peer-limit"].stringValue,
                         //"Tracker",
                         //"Tracker Update",
                         "Last Active: " + lastactive
                ]
                var completed = timestampToDate(stamp: torrent!["doneDate"].intValue)
                if completed == "01 Jan 70"{
                    completed = "N/A"
                }
                tData = [
                    "Location: " + torrent!["downloadDir"].stringValue,
                    "Error: " + torrent!["error"].stringValue,
                    "Remaining: " + ByteCountFormatter.string(fromByteCount: torrent!["leftUntilDone"].int64Value, countStyle: .file),
                    "Created On: " + torrent!["error"].stringValue,
                    "Total Size : " + ByteCountFormatter.string(fromByteCount: torrent!["totalSize"].int64Value, countStyle: .file),
                    "Pieces: " + torrent!["pieceCount"].stringValue,
                    "Hash: " + torrent!["hashString"].stringValue,
                    "Comments: " + torrent!["comment"].stringValue,
                    "Added: " +  timestampToDate(stamp: torrent!["addedDate"].intValue),
                    "Completed: " + completed,
                ]
                store.downloadDir = torrent!["downloadDir"].stringValue
                
//                [PropertiesItem(  name: "Name",
//                                           value: torrent!["name"].string!),
//                              PropertiesItem(  name: "Status",
//                                           value: status)
//                ]
                              
        }
        
    }
    func showFilePicker(transferId: Int, info: (config: TransmissionConfig, auth: TransmissionAuth)) {
        DispatchQueue.main.async {
            store.transferToSetFiles = transferId
            store.isShowingTorrentInfoDialog.toggle()
            store.isShowingTransferFiles.toggle()
        }
    }

}

//#Preview {
//    TorrentInfoFrame()
//}
