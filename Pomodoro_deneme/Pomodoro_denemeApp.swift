//
//  Pomodoro_denemeApp.swift
//  Pomodoro_deneme
//
//  Created by Ahmet Mert Şengöl on 5.07.2025.
//

import SwiftUI

@main
struct Pomodoro_denemeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
