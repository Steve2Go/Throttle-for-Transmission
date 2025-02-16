//
//  Imdl.swift
//  Throttle for Transmission
//
//  Created by Stephen Grigg on 6/2/2025.
//
#if os(macOS)
import Foundation
import SwiftUI

func imdl( store: Store){
    var result = ""
let nsHome = NSHomeDirectory()
    if !FileManager.default.fileExists( atPath: nsHome + "/imdl"){
        print("Getting intermodal binary..")
        store.imdlProgress = "Getting intermodal binary.."
        var script = "/usr/bin/curl --proto '=https' --tlsv1.2 -sSf https://imdl.io/install.sh | bash -s -- --to " + nsHome
        var output = shell(script)
        print(output)
    }
    print("intermodal installed, creating...")
    store.imdlProgress = store.imdlProgress + "intermodal installed, creating..."
    var cmd = nsHome + store.imdlCmd
    print (cmd)
    var output = shell(cmd)
    print(output)
    store.imdlProgress = output
    if output.contains("Done!"){
        store.imdlSuccess = true
    }
//    if output.contains("Done!"){
//        store.imdlSuccess = true
//        
//    }
}
//        if store.imdlCP[1] != ""{
//            let fileArray = store.imdlCP[0].components(separatedBy: "/")
//            let finalFileName = fileArray.last
//            
//            let fileManager = FileManager()
//            var isDir : ObjCBool = false
//            if fileManager.fileExists(atPath: store.imdlCP[0], isDirectory:&isDir) {
//                
//                if isDir.boolValue  == true{
//                    //copy -r and is dir
//                    cmd = "/bin/cp -R " + store.imdlCP[0] + " " + store.imdlCP[1]
//                    cmd1 = "/bin/chmod 775 -R " + store.imdlCP[1] + "/" + finalFileName!
//                }
//                else{
//                    // copy and is not dir
//                    cmd = "/bin/cp " + store.imdlCP[0] + " " + store.imdlCP[1]
//                    cmd1 = "/bin/chmod 775 " + store.imdlCP[1] + "/" + finalFileName!
//                }
//            }
//                
//            store.imdlProgress = store.imdlProgress + """
//                            Torrent Created, moving to new location...
//                            """
//                var output = shell(cmd)
//            print (output)
//            store.imdlProgress =  store.imdlProgress + """
//                                                        """ +  output
//            
//            output = shell(cmd1)
//        print (output)
//        store.imdlProgress =  store.imdlProgress + """
//                                                    """ +  output
//            
//            

                //try fileManager.copyItem(atPath: store.imdlCP[0], toPath: store.imdlCP[1])
//            } catch {
//                print(error.localizedDescription)
//                store.imdlProgress = "The torrent was created, but there was an issue moving the file: " + error.localizedDescription + " Please move your file manually.)"
//            }
      // }
       //
 

func shell(_ command: String) -> String {

let task = Process()
let pipe = Pipe()

task.standardOutput = pipe
task.standardError = pipe
task.arguments = ["-c", command]
task.launchPath = "/bin/zsh"
task.standardInput = nil
task.launch()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
let output = String(data: data, encoding: .utf8)!

return output
}
#endif
