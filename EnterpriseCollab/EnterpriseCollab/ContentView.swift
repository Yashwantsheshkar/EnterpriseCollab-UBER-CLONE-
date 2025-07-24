//
//  ContentView.swift
//  EnterpriseCollab
//
//  Created by Yashwant Sheshkar on 23/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.currentUser?.userType == .rider {
                    RiderHomeView()
                } else {
                    DriverHomeView()
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
