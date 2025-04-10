import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        Group {
            if session.session != nil {
                MainTabView()
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
