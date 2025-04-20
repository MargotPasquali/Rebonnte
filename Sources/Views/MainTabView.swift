import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var aisleViewModel = AisleListViewModel()

    init() {
        // Customize the appearance of the UITabBar
        let tabBarAppearance = UITabBar.appearance()

        // Color of unselected items
        tabBarAppearance.unselectedItemTintColor = UIColor.text

        // Color of selected items
        tabBarAppearance.tintColor = UIColor(named: "Action")

        // Background color of the bar
        tabBarAppearance.backgroundColor = UIColor.background

        // Disable the default highlight (selection indicator)
        tabBarAppearance.standardAppearance.selectionIndicatorTintColor = nil

        // Customize the font of tab titles
        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: UIFont(name: "Nunito-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)],
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
