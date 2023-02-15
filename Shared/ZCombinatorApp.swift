//
//  ZCombinatorApp.swift
//  Shared
//
//  Created by Jiaqi Feng on 7/18/22.
//

import SwiftUI

@main
struct ZCombinatorApp: App {
    let auth = Authentication()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(self.auth)
        }
    }
}
