//
//  practiceUKDApp.swift
//  practiceUKD
//
//  Created by Viktor Kizera on 6/12/25.
//

import SwiftUI

@main
struct practiceUKDApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
