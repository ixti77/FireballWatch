
import SwiftUI
import CoreData
import os.log

struct ContentView: View {
  @EnvironmentObject private var persistence: PersistenceController
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    TabView {
      FireballList().tabItem {
        VStack {
          Image(systemName: "sun.max.fill")
          Text("Fireballs")
        }
      }
      .tag(1)
      FireballGroupList().tabItem {
        VStack {
          Image(systemName: "tray.full.fill")
          Text("Groups")
        }
      }
      .tag(2)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
      .environmentObject(PersistenceController.preview)
  }
}
