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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
