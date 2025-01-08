//
//  LocationPicker.swift
//  Mission
//
//  Created by Stephen Grigg on 7/1/2025.
//

import SwiftUI

struct LocationPicker: View {
    @ObservedObject var store: Store
    @State var downloadDir: String = ""
    @State var isOn: Bool = true
    @State private var showFileImporter = false
    
    var body: some View {
        VStack{
            HStack {

                 Spacer()
                Button(action: {
                    store.isShowingLocation.toggle()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                }).buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 10)
                        .padding(.bottom, 0)
              }
            Text("Download Location")
                .font(.headline)
                .padding(.leading, 10)
                .padding(.bottom, 10)
                .padding(.top, 0)
//            Toggle(isOn: $isOn) {
//                        Text("Move Files to new location")
//                    }
            
        }
        HStack{
            TextField(
                "Download Destination",
                text: $downloadDir
            )
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
            
            Button("Save"){
                DispatchQueue.main.async {
                    let info = makeConfig(store: store)
                    setLocation(torrentID: store.currentTorrentId!, path: downloadDir, config: info.config, auth: info.auth, onUpd: { i in
                            dump(i)
                    })
                    store.isShowingLocation.toggle()
                }
            }
        }.padding([.leading, .trailing])
            .padding(.bottom, 20)
        .onAppear{
            //get current dir
            downloadDir = store.downloadDir
            
        }
    }
}

//#Preview {
//    LocationPicker(store: store)
//}
