import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    init() {
        // Auto-login for demo
        // Uncomment to start with login screen
        // isAuthenticated = false
    }
    
    func login(email: String, password: String, userType: UserType) {
        // Mock authentication
        currentUser = User(
            name: userType == .rider ? "John Rider" : "Mike Driver",
            email: email,
            userType: userType
        )
        isAuthenticated = true
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
