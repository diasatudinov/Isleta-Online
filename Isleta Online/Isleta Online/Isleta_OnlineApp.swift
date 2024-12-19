//
//  Isleta_OnlineApp.swift
//  Isleta Online
//
//  Created by Dias Atudinov on 16.12.2024.
//

import SwiftUI

@main
struct Isleta_OnlineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
           
        }
    }
}
