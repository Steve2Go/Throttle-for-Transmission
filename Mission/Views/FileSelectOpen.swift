
import Foundation
import SwiftUI
import SwiftyJSON

struct MultipleSelectionRow: View {
    var title: String
    @State var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Toggle(self.title, isOn: self.$isSelected)
                .onChange(of: isSelected) { i in
                    action()
                }
        }
    }
}

struct FileSelectDialog: View {
    @ObservedObject var store: Store = Store()
    
    @State var files: [File] = []
    //@State var selections: [Int] = []
    @State var added: [FileWithId] = []
    @State var removed: [FileWithId] = []
    init(store: Store) {
        self.store = store
    }
    @State private var selection: FileWithId.ID?
    @State private var unselection: FileWithId.ID?
    
    var body: some View {
        VStack {
            HStack {
                Text("Select Files")
                    .font(.headline)
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                Button(action: {
                    store.isShowingTransferFiles.toggle()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                        .frame(alignment: .trailing)
                }).buttonStyle(BorderlessButtonStyle())
            }
            
            HStack {
                VStack {
                    Table(added, selection: $selection) {
                        TableColumn("Downloading", value: \.name)
                        }
                    .onChange(of: selection, perform: { selected in
                                    // called each time on table selection changes
                        if added.first(where: { $0.id == selected }) != nil {
                            removed.append(added.first(where: { $0.id == selected })!)
                            self.added.removeAll(where: { $0.id == selected })
                            selection = nil
                            unselection = nil
                        }
                                })
                }
                VStack{
                    Button {
                        removed.append(contentsOf: added)
                        self.added.removeAll()
                    } label: {
                        Image(systemName: "forward.end.circle")

                    }
                    Button {
                        added.append(contentsOf: removed)
                        self.removed.removeAll()
                    } label: {
                        Image(systemName: "backward.end.circle")

                    }
                }
                VStack {
                    Table(removed, selection: $unselection) {
                        TableColumn("Unwanted", value: \.name)
                        }
                    .onChange(of: unselection, perform: { selected in
                        //let item = removed.first(where: { $0.id == selected })
                        if removed.first(where: { $0.id == selected }) != nil {
                            added.append(removed.first(where: { $0.id == selected })!)
                            self.removed.removeAll(where: { $0.id == selected })
                            unselection = nil
                            selection = nil
                        }
                                })
                    
                }
            }
            //            List {
//                ForEach(Array(store.addTransferFilesList.enumerated()), id: \.offset) { (i,f) in
//                    MultipleSelectionRow(title: f.name, isSelected: store.fileSelections.contains(i)) {
//                        if store.fileSelections.contains(i) {
//                            print("remove \(i)")
//                            store.fileSelections.removeAll(where: { $0 == i })
//                        } else {
//                            print("add \(i)")
//                            store.fileSelections.append(i)
//                        }
//                    }
//                }
//            }
            Button("Submit") {
                var dontDownload: [Int] = [0]
                dontDownload.removeAll()
                for rem in removed {
                    dontDownload.append(rem.id)
                }
                var doDownload: [Int] = [0]
                doDownload.removeAll()
                for add in added {
                    doDownload.append(add.id)
                }

                print("Don't download: \(dontDownload)")
                print("Do download: \(doDownload)")
                store.isShowingTransferFiles.toggle()
                DispatchQueue.main.async {
                    let info = makeConfig(store: store)
                    setTransferFiles(transferId: store.transferToSetFiles, files: dontDownload, mutation: "files-unwanted", info: info) { i in
                        
                    }
                    setTransferFiles(transferId: store.transferToSetFiles, files: doDownload, mutation: "files-wanted", info: info) { i in
                        
                    }
                }
            }.padding()
                .onAppear {
                    let info = makeConfig(store: store)
                    getTransferFiles(transferId: store.transferToSetFiles, info: info, onReceived: { f,s in
                        added = f
                        removed = s
                    })
//                    store.fileSelections = store.fileSelections
//                    dump(store.fileSelections)
                }
//                    DispatchQueue.main.async {
//                        store.fileSelections.removeAll()
//                        let fileinfo = JSON(store.addTransferFilesInfo)
//                        for (i, el) in fileinfo.enumerated() {{
//                            if el["wanted"].stringValue == "false" {
//                                store.fileSelections.append(i)
//                            }
//                            
//                        }
//                    }
//                    
//                    //selections = []
//                }
        }
    }
}
