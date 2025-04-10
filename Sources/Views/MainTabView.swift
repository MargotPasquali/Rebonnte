import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var aisleViewModel = AisleListViewModel()

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.text
        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: UIFont(name: "Nuni-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)],
            for: .normal
        )
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            TabView {
                AisleListView(viewModel: aisleViewModel)
                    .tabItem {
                        Image(systemName: "list.dash")
                            .foregroundStyle(Color.text)
                        Text("Aisles")
                    }
                AllMedicinesView()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("All Medicines")
                    }
                UserAccountView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
            }
            .accentColor(.action)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SessionStore().withFakeUser())
}
