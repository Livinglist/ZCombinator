//
//  ZCombinatorApp.swift
//  Shared
//
//  Created by Jiaqi Feng on 7/18/22.
//

import SwiftUI

@main
struct ZCombinatorApp: App {
    let persistenceController = PersistenceController.shared
    let authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(self.authViewModel)
        }
    }
}
