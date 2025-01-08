//
//  ListEntry.swift
//  Mission
//
//  Created by Joe Diragi on 3/3/22.
//

import Foundation
import SwiftUI
import KeychainAccess

struct ListRow: View {
    @Binding var torrent: Torrent
    @State var deleteDialog: Bool = false
    @State var statusColor = Color.green
    var store: Store
    
    var body: some View {
        HStack {
            VStack {
                Text(torrent.name)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom, 1)
                
                if torrent.recheckProgress > 0{
                    ProgressView(value: torrent.recheckProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: store.color[torrent.status]))
                }else{
                    ProgressView(value: torrent.percentComplete)
                        .progressViewStyle(LinearProgressViewStyle(tint: store.color[torrent.status]))
                }
                
                
                if torrent.status == TorrentStatus.seeding.rawValue {
                    Text("Seeding to \(torrent.peersConnected - torrent.peersSendingToUs) of \(torrent.peersConnected) peers, Added: " + timestampToDate(stamp: torrent.addedDate))
                        .font(.custom("sub", size: 10))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                } else if (torrent.status == TorrentStatus.downloading.rawValue) {
                    Text("Downloading from \(torrent.peersSendingToUs) of \(torrent.peersConnected) peers, Added: " + timestampToDate(stamp: torrent.addedDate))
                        .font(.custom("sub", size: 10))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                } else{
                    Text(store.status[torrent.status] + " Added: " + timestampToDate(stamp: torrent.addedDate))
                        .font(.custom("sub", size: 10))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                             
                
            }.padding([.top, .bottom, .leading], 10)
                .padding(.trailing, 5)
                .contentShape(Rectangle())
                .onTapGesture {
                    let info = makeConfig(store: store)
                    store.isShowingTorrentInfoDialogUpdate = false
                    store.showTorrentInfo(transferId: torrent.id, info: info)
                }
            
            //Text(timestampToDate(stamp: torrent.addedDate))
            Button(action: {
                let info = makeConfig(store: store)
                playPause(torrent: torrent, config: info.config, auth: info.auth, onResponse: { response in
                    // TODO: Handle response
                })
            }, label: {
                Image(systemName: torrent.status == TorrentStatus.stopped.rawValue ? "play.circle" : "pause.circle")
            }) .buttonStyle(BorderlessButtonStyle())
                .frame(width: 10, height: 10, alignment: .center)
                .padding(.trailing, 5)
            
            if store.testPathmap(){
                Button(action: {
                    let str = torrent.downloadDir + "/" + torrent.name
                    
                    if let range = str.range(of: store.pathMap[0]) {
                        let path = str.replacingCharacters(in: range, with:store.pathMap[1])
                        NSWorkspace.shared.activateFileViewerSelecting([URL(filePath: path)])
                    }
                }, label: {
                    Image(systemName: "externaldrive")
                }) .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 10, height: 10, alignment: .center)
                    .padding(.trailing, 5)
            }
           
            Menu {
                Menu {
                    Button("High") {
                        setPriority(torrent: torrent, priority: TorrentPriority.high, info: makeConfig(store: store), onComplete: { r in })
                    }
                    Button("Normal") {
                        setPriority(torrent: torrent, priority: TorrentPriority.normal, info: makeConfig(store: store), onComplete: { r in })
                    }
                    Button("Low") {
                        setPriority(torrent: torrent, priority: TorrentPriority.low, info: makeConfig(store: store), onComplete: { r in })
                    }
                } label: {
                    Text("Set priority")
                }
                Button("Reannonunce", action: {
                    let info = makeConfig(store: store)
                    requestForTorrent(torrent: torrent, method: "torrent-announce", config: info.config, auth: info.auth, onUpd: { response in
                        // TODO: Handle response
                    })
                                 })
                Button("Verify", action: {
                    let info = makeConfig(store: store)
                    requestForTorrent(torrent: torrent, method: "torrent-verify", config: info.config, auth: info.auth, onUpd: { response in
                        // TODO: Handle response
                    })
                                 })
                                Button("Delete", action: {
                                    deleteDialog.toggle()
                                })
                
                Button("Files", action: {
                    let info = makeConfig(store: store)
                    showFilePicker(transferId: torrent.id, info: info)
                })
                 //TODO: Move the File Picker
//                                })
                
                
                //                 Button("Move", action: {
                //                 //TODO: Set Location screen
                //                 })
                
//                 Button("Download", action: {
//                 //TODO: Download the destination folder using sftp library
//                 })
            } label: {
                //Image (systemName: "ellipsis.circle")
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(width: 10, height: 10, alignment: .center)
            .buttonStyle(BorderlessButtonStyle())
                .frame(width: 10, height: 10, alignment: .center)
                .padding(.trailing, 5)
        }
        // Ask to delete files on disk when removing transfer
        .alert(
            "Remove Transfer",
            isPresented: $deleteDialog) {
                Button(role: .destructive) {
                    let info = makeConfig(store: store)
                    deleteTorrent(torrent: torrent, erase: true, config: info.config, auth: info.auth, onDel: { response in
                        // TODO: Handle response
                    })
                    deleteDialog.toggle()
                } label: {
                    Text("Delete files")
                }
                Button("Don't delete") {
                    let info = makeConfig(store: store)
                    deleteTorrent(torrent: torrent, erase: false, config: info.config, auth: info.auth, onDel: { response in
                        // TODO: Handle response
                    })
                    deleteDialog.toggle()
                }
            } message: {
                Text("Would you like to delete the transfered files from disk?")
            }.interactiveDismissDisabled(false)
    }
        
    func showFilePicker(transferId: Int, info: (config: TransmissionConfig, auth: TransmissionAuth)) {
        store.transferToSetFiles = transferId
        store.isShowingTransferFiles.toggle()
        }
    
}
