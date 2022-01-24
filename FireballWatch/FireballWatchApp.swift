

import SwiftUI

@main
struct FireballWatchApp: App {
  @Environment(\.scenePhase) private var scenePhase
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.viewContext)
        .environmentObject(persistenceController)
    }
    .onChange(of: scenePhase) { phase in
      switch phase {
      case .background:
        persistenceController.saveViewContext()
      default:
        break
      }
    }
  }
}
