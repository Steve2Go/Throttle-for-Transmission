//
//  Settings.swift
//  Mission
//
//  Created by Stephen Grigg on 8/1/2025.
//

import SwiftUI

struct SettingsView: View {
    //@ObservedObject var store: Store
    @State var reOpen = false
    @State var deleteFile = false
    @State var  chooseeFiles = false
    var body: some View {
        VStack{
            //Tabs
//            Toggle("Open last used Tabs on Exit", isOn: $reOpen)
//                .padding([.leading, .trailing], 20)
//                .padding([.top, .bottom], 10)
//                .onAppear { reOpen = UserDefaults.standard.bool(forKey: "reOpen")}
//                .onDisappear { UserDefaults.standard.setValue(reOpen, forKey: "reOpen") }
//            Text("Use CTRL + COMMAND + \\ or View Menu to toggle tabs")
//                .font(.system(size: 8))
//                .padding(.leading, 20)
            
            Toggle("Delete Torrent Files on Upload", isOn: $deleteFile)
                .padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 10)
                .onAppear { deleteFile = UserDefaults.standard.bool(forKey: "deleteFile")}
                .onDisappear {UserDefaults.standard.setValue(deleteFile, forKey: "deleteFile")}
            Toggle("Choose files to download on adding Torrent File", isOn: $chooseeFiles)
                .padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 10)
                .onAppear { chooseeFiles = UserDefaults.standard.bool(forKey: "chooseeFiles")}
                .onDisappear {UserDefaults.standard.setValue(chooseeFiles, forKey: "chooseeFiles")}
            Toggle("Open Last Server (instead of Default)", isOn: $reOpen)
                .padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 10)
                .onAppear { reOpen = UserDefaults.standard.bool(forKey: "reOpen")}
                .onDisappear {UserDefaults.standard.setValue(reOpen, forKey: "reOpen")}
            Button(action: {makeDefaultMagnetHandler() }) {
                Text("Associate .torrent Files and magnet Links")
            }.padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 10)
            
        }
        }
        
    }
func makeDefaultMagnetHandler() {
    NSWorkspace.shared.setDefaultApplication(at: Bundle.main.bundleURL, toOpenURLsWithScheme: "magnet") { error in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
        NSWorkspace.shared.setDefaultApplication(at: Bundle.main.bundleURL, toOpen: .torrent) { error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
    }
}

//#Preview {
//    Settings()
//}
