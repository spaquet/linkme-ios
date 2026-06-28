//
//  LinkMeApp.swift
//  LinkMe
//
//  Created by Stéphane PAQUET on 6/8/26.
//

import SwiftUI

/// The main app entry point.
///
/// Configures the app window and light color scheme.
@main
struct LinkMeApp: App {
    /// The app's primary window scene.
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
    }
}
