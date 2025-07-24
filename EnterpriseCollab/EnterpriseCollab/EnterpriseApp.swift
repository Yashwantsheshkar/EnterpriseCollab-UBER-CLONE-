//
//  EnterpriseCollabApp.swift
//  EnterpriseCollab
//
//  Created by Yashwant Sheshkar 
//

import SwiftUI

@main
struct EnterpriseApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var rideViewModel = RideViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(locationViewModel)
                .environmentObject(rideViewModel)
                .environmentObject(chatViewModel)
        }
    }
}


