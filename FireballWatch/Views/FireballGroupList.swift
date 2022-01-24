import SwiftUI
import CoreData

struct FireballGroupList: View {
  static var fetchRequest: NSFetchRequest<FireballGroup> {
    let request: NSFetchRequest<FireballGroup> = FireballGroup.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \FireballGroup.name, ascending: true)]
    return request
  }
  @EnvironmentObject private var persistence: PersistenceController
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    fetchRequest: FireballGroupList.fetchRequest,
    animation: .default)
  private var groups: FetchedResults<FireballGroup>

  @State var addGroupIsPresented = false

  var body: some View {
    NavigationView {
      List {
        ForEach(groups, id: \.id) { group in
          NavigationLink(destination: FireballGroupDetailsView(fireballGroup: group)) {
						HStack {
							Text("\(group.name ?? "Untitled")")
							Spacer()
							Image(systemName: "sun.max.fill")
							Text("\(group.fireballCount)")
						}
          }
        }
        .onDelete(perform: deleteObjects)
      }
      .sheet(isPresented: $addGroupIsPresented) {
        AddFireballGroup { name in
          addNewGroup(name: name)
          addGroupIsPresented = false
        }
      }
      .navigationBarTitle(Text("Fireball Groups"))
      .navigationBarItems(trailing:
        // swiftlint:disable:next multiple_closures_with_trailing_closure
        Button(action: { addGroupIsPresented.toggle() }) {
          Image(systemName: "plus")
        }
      )
    }
  }

  private func deleteObjects(offsets: IndexSet) {
    withAnimation {
      persistence.deleteManagedObjects(offsets.map { groups[$0] })
    }
  }

  private func addNewGroup(name: String) {
    withAnimation {
      persistence.addNewFireballGroup(name: name)
    }
  }
}

struct GroupList_Previews: PreviewProvider {
  static var previews: some View {
    FireballGroupList()
      .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
      .environmentObject(PersistenceController.preview)
  }
}
