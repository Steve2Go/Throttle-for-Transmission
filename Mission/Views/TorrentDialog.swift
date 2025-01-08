//
//  TorrentView.swift
//  Mission
//
//  Created by Stephen Grigg on 4/1/2025.
//

import SwiftUI

struct TorrentDialog: View {
    @ObservedObject var store: Store
    //get the torrent object
    @State var torrentId: Int? = 0
    @State var torrent: [File]?
    
    //Send it to the framse on appear
    
    var body: some View {
        VStack {
            Button(action: {
                store.isShowingTorrentDialog.toggle()
                store.urlWaiting = ""
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .frame(alignment: .trailing)
            }).buttonStyle(BorderlessButtonStyle())
            TabView {
                TorrentInfoDialog(store:store)
                    .tabItem {
                        Label("Information", systemImage: "chart.bar.xaxis")
                    }
                
                FileSelectDialog()
                    .tabItem {
                        Label("Files", systemImage: "text.document")
                    }
            }.onAppear{
                //            let torrentId = store.currentTorrentId!
                //            let info = makeConfig(store: store)
                //            getTransferInfo(transferId: torrentId, info: info, onReceived: { torrents in
                //                torrent = torrents
                //            })
            }
        }}
}

