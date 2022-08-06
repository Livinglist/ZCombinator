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
    
    init(){
//        Task {
//            await AuthRepository.shared.login(username: "livinglist", password: "fjq11038")
//        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
