import Foundation

/// Service class for handling all authentication-related API calls
final class AuthService {
    
    // MARK: - Singleton
    
    static let shared = AuthService()
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    /// Logs in a user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    ///   - userType: Rider or Driver
    /// - Returns: AuthResponse containing user and tokens
    func login(email: String, password: String, userType: UserType) async throws -> AuthResponse {
        struct LoginRequest: Codable {
            let email: String
            let password: String
            let userType: String
        }
        
        let request = LoginRequest(
            email: email,
            password: password,
            userType: userType.rawValue
        )
        
        let response: AuthResponse = try await networkManager.request(.login, body: request)
        
        // Store tokens
        networkManager.setAuthToken(response.token)
        networkManager.setRefreshToken(response.refreshToken)
        
        return response
    }
    
    /// Registers a new user
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - password: User's password
    ///   - userType: Rider or Driver
    /// - Returns: AuthResponse containing user and tokens
    func register(
        name: String,
        email: String,
        password: String,
        userType: UserType
    ) async throws -> AuthResponse {
        struct RegisterRequest: Codable {
            let name: String
            let email: String
            let password: String
            let userType: String
        }
        
        let request = RegisterRequest(
            name: name,
            email: email,
            password: password,
            userType: userType.rawValue
        )
        
        let response: AuthResponse = try await networkManager.request(.register, body: request)
        
        // Store tokens
        networkManager.setAuthToken(response.token)
        networkManager.setRefreshToken(response.refreshToken)
        
        return response
    }
    
    /// Logs out the current user
    func logout() async throws {
        try await networkManager.requestVoid(.logout)
        networkManager.clearTokens()
    }
    
    /// Requests a password reset email
    /// - Parameter email: User's email address
    func forgotPassword(email: String) async throws {
        try await networkManager.requestVoid(.forgotPassword(email: email))
    }
    
    /// Resets the user's password with a token
    /// - Parameters:
    ///   - token: Reset token from email
    ///   - newPassword: New password
    func resetPassword(token: String, newPassword: String) async throws {
        struct ResetRequest: Codable {
            let token: String
            let newPassword: String
        }
        
        try await networkManager.requestVoid(.resetPassword, body: ResetRequest(token: token, newPassword: newPassword))
    }
    
    /// Gets the current user's profile
    /// - Parameter userId: User's ID
    /// - Returns: User object
    func getUser(id: String) async throws -> User {
        return try await networkManager.request(.getUser(id: id))
    }
    
    /// Updates the current user's profile
    /// - Parameters:
    ///   - userId: User's ID
    ///   - name: Updated name (optional)
    ///   - profileImageUrl: Updated profile image URL (optional)
    /// - Returns: Updated User object
    func updateUser(
        id: String,
        name: String? = nil,
        profileImageUrl: String? = nil
    ) async throws -> User {
        struct UpdateRequest: Codable {
            let name: String?
            let profileImageUrl: String?
        }
        
        let request = UpdateRequest(name: name, profileImageUrl: profileImageUrl)
        return try await networkManager.request(.updateUser(id: id), body: request)
    }
    
    // MARK: - Validation Helpers
    
    /// Validates email format
    /// - Parameter email: Email to validate
    /// - Returns: True if valid
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates password strength
    /// - Parameter password: Password to validate
    /// - Returns: True if valid (at least 6 characters)
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    /// Checks if user is currently authenticated
    var isAuthenticated: Bool {
        networkManager.isAuthenticated
    }
}
