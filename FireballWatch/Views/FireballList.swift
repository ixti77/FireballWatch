

import SwiftUI
import CoreData

struct FireballList: View {
  static var fetchRequest: NSFetchRequest<Fireball> {
    let request: NSFetchRequest<Fireball> = Fireball.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Fireball.dateTimeStamp, ascending: true)]
    return request
  }

  @EnvironmentObject private var persistence: PersistenceController
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    fetchRequest: FireballList.fetchRequest,
    animation: .default)
  private var fireballs: FetchedResults<Fireball>

  var body: some View {
    NavigationView {
      List {
        ForEach(fireballs, id: \.dateTimeStamp) { fireball in
          NavigationLink(destination: FireballDetailsView(fireball: fireball)) {
            FireballRow(fireball: fireball)
          }
        }
        .onDelete(perform: deleteObjects)
      }
      .navigationBarTitle(Text("Fireballs"))
      .navigationBarItems(trailing:
        // swiftlint:disable:next multiple_closures_with_trailing_closure
        Button(action: { persistence.fetchFireballs() }) {
          Image(systemName: "arrow.2.circlepath")
        }
      )
    }
  }

  private func deleteObjects(offsets: IndexSet) {
    withAnimation {
      persistence.deleteManagedObjects(offsets.map { fireballs[$0] })
    }
  }
}


struct FireballList_Previews: PreviewProvider {
  static var previews: some View {
    FireballList()
      .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
      .environmentObject(PersistenceController.preview)
  }
}
