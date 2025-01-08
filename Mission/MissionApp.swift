import SwiftUI
import Combine
import AlertToast
import KeychainAccess

@main
struct MissionApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene { 
        WindowGroup(id: "main") {
            ContentView()
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        Settings {
                 SettingsView()
             }
        
    }
}
