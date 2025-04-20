import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var medicineViewModel = MedicineListViewModel()
    
    var body: some View {
        Group {
            if session.session != nil {
                MainTabView()
                    .environmentObject(medicineViewModel)
            } else {
                LoginView()
            }
        }
        .preferredColorScheme(
            session.appearancePreference == .system ? nil :
            (session.appearancePreference == .dark ? .dark : .light)
        )
        .onAppear {
            session.listen()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}
