//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

//import SwiftUI
//
//
//@main
//struct MediStockApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    var sessionStore = SessionStore()
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(sessionStore)
//        }
//    }
//}


import Foundation
import UIKit
import FirebaseAppCheck
import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure App Check with debug provider
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        // FirebaseApp.configure() n'est plus nécessaire ici si déplacé dans init de MediStockApp
        
        return true
    }
}



@main
struct MediStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var sessionStore: SessionStore
    
    init() {
        FirebaseApp.configure()
        self.sessionStore = SessionStore()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
        }
    }
}
