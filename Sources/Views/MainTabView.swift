import SwiftUI

struct MainTabView: View {
    @State private var darkMode: Bool = false
    var body: some View {
        TabView {
            AisleListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Aisles")
                }

            AllMedicinesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("All Medicines")
                }
            
            UserAccountView(darkMode: $darkMode)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
        }
    }
}

#Preview {
    MainTabView()
}
