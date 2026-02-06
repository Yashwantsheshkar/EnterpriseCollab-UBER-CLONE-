import Foundation

/// HTTP methods supported by the API
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

/// Defines all API endpoints in a type-safe manner
/// Each case represents a specific API endpoint with its path and method
enum APIEndpoint {
    
    // MARK: - Base Configuration
    
    /// Base URL for the API - Change this for your backend
    static let baseURL = "https://api.yourbackend.com/v1"
    
    // MARK: - Authentication Endpoints
    
    case login
    case register
    case logout
    case refreshToken
    case forgotPassword(email: String)
    case resetPassword
    
    // MARK: - User Endpoints
    
    case getUser(id: String)
    case updateUser(id: String)
    case uploadProfileImage
    case updateLocation
    
    // MARK: - Ride Endpoints
    
    case requestRide
    case getRide(id: String)
    case getAvailableRides
    case getRideHistory
    case acceptRide(rideId: String)
    case declineRide(rideId: String)
    case startRide(rideId: String)
    case completeRide(rideId: String)
    case cancelRide(rideId: String)
    case updateRideStatus(rideId: String)
    case rateRide(rideId: String)
    
    // MARK: - Driver Endpoints
    
    case driverGoOnline
    case driverGoOffline
    case getDriverStats
    case getEarnings
    
    // MARK: - Chat Endpoints
    
    case getMessages(rideId: String)
    case sendMessage(rideId: String)
    
    // MARK: - Payment Endpoints
    
    case getPaymentMethods
    case addPaymentMethod
    case deletePaymentMethod(id: String)
    case processPayment(rideId: String)
    
    // MARK: - Path Property
    
    /// The URL path for this endpoint
    var path: String {
        switch self {
        // Auth
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh"
        case .forgotPassword(let email):
            return "/auth/forgot-password?email=\(email)"
        case .resetPassword:
            return "/auth/reset-password"
            
        // User
        case .getUser(let id):
            return "/users/\(id)"
        case .updateUser(let id):
            return "/users/\(id)"
        case .uploadProfileImage:
            return "/users/profile-image"
        case .updateLocation:
            return "/users/location"
            
        // Rides
        case .requestRide:
            return "/rides"
        case .getRide(let id):
            return "/rides/\(id)"
        case .getAvailableRides:
            return "/rides/available"
        case .getRideHistory:
            return "/rides/history"
        case .acceptRide(let rideId):
            return "/rides/\(rideId)/accept"
        case .declineRide(let rideId):
            return "/rides/\(rideId)/decline"
        case .startRide(let rideId):
            return "/rides/\(rideId)/start"
        case .completeRide(let rideId):
            return "/rides/\(rideId)/complete"
        case .cancelRide(let rideId):
            return "/rides/\(rideId)/cancel"
        case .updateRideStatus(let rideId):
            return "/rides/\(rideId)/status"
        case .rateRide(let rideId):
            return "/rides/\(rideId)/rate"
            
        // Driver
        case .driverGoOnline:
            return "/driver/online"
        case .driverGoOffline:
            return "/driver/offline"
        case .getDriverStats:
            return "/driver/stats"
        case .getEarnings:
            return "/driver/earnings"
            
        // Chat
        case .getMessages(let rideId):
            return "/rides/\(rideId)/messages"
        case .sendMessage(let rideId):
            return "/rides/\(rideId)/messages"
            
        // Payment
        case .getPaymentMethods:
            return "/payments/methods"
        case .addPaymentMethod:
            return "/payments/methods"
        case .deletePaymentMethod(let id):
            return "/payments/methods/\(id)"
        case .processPayment(let rideId):
            return "/payments/process/\(rideId)"
        }
    }
    
    // MARK: - HTTP Method Property
    
    /// The HTTP method for this endpoint
    var method: HTTPMethod {
        switch self {
        // GET requests
        case .getUser, .getRide, .getAvailableRides, .getRideHistory,
             .getDriverStats, .getEarnings, .getMessages, .getPaymentMethods,
             .forgotPassword:
            return .GET
            
        // POST requests
        case .login, .register, .logout, .refreshToken, .resetPassword,
             .uploadProfileImage, .requestRide, .acceptRide, .declineRide,
             .startRide, .completeRide, .cancelRide, .driverGoOnline,
             .driverGoOffline, .sendMessage, .addPaymentMethod, .processPayment,
             .rateRide:
            return .POST
            
        // PUT requests
        case .updateUser, .updateLocation, .updateRideStatus:
            return .PUT
            
        // DELETE requests
        case .deletePaymentMethod:
            return .DELETE
        }
    }
    
    // MARK: - Full URL
    
    /// The complete URL for this endpoint
    var url: URL? {
        URL(string: APIEndpoint.baseURL + path)
    }
    
    // MARK: - Requires Authentication
    
    /// Whether this endpoint requires authentication
    var requiresAuth: Bool {
        switch self {
        case .login, .register, .forgotPassword, .resetPassword:
            return false
        default:
            return true
        }
    }
    
    // MARK: - Helper Properties
    
    /// Whether this is the refresh token endpoint (for avoiding infinite loops)
    var isRefreshToken: Bool {
        if case .refreshToken = self {
            return true
        }
        return false
    }
}
