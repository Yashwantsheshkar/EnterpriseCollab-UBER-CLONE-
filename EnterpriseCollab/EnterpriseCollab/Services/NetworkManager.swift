import Foundation

/// Central networking class that handles all HTTP requests
/// Uses async/await for modern Swift concurrency
final class NetworkManager {
    
    // MARK: - Singleton
    
    static let shared = NetworkManager()
    
    // MARK: - Properties
    
    private var authToken: String?
    private var refreshToken: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    /// Whether to use mock data instead of real API calls
    /// Set to true for development/testing
    var useMockData = true
    
    // MARK: - Initialization
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Token Management
    
    /// Sets the authentication token for subsequent requests
    func setAuthToken(_ token: String) {
        self.authToken = token
        // TODO: Store in Keychain for persistence
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    /// Sets the refresh token for token renewal
    func setRefreshToken(_ token: String) {
        self.refreshToken = token
        // TODO: Store in Keychain for persistence
        UserDefaults.standard.set(token, forKey: "refreshToken")
    }
    
    /// Clears all authentication tokens
    func clearTokens() {
        self.authToken = nil
        self.refreshToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
    
    /// Loads stored tokens from persistence
    func loadStoredTokens() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
    }
    
    /// Returns whether user has a valid auth token
    var isAuthenticated: Bool {
        authToken != nil
    }
    
    // MARK: - Generic Request Method
    
    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - body: Optional request body (Encodable)
    ///   - retryCount: Number of retry attempts (default: 1)
    /// - Returns: Decoded response of type T
    func request<T: Codable>(
        _ endpoint: APIEndpoint,
        body: Encodable? = nil,
        retryCount: Int = 1
    ) async throws -> T {
        
        // Use mock data if enabled
        if useMockData {
            return try await mockRequest(endpoint, body: body)
        }
        
        // Build URL
        guard let url = endpoint.url else {
            throw APError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if required
        if endpoint.requiresAuth {
            guard let token = authToken else {
                throw APError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode body if present
        if let body = body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw APError.encodingError(error)
            }
        }
        
        // Log request (debug only)
        #if DEBUG
        logRequest(request)
        #endif
        
        // Perform request
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw APError.noInternetConnection
            case .timedOut:
                throw APError.timeout
            default:
                throw APError.networkError(error)
            }
        } catch {
            throw APError.networkError(error)
        }
        
        // Log response (debug only)
        #if DEBUG
        logResponse(response, data: data)
        #endif
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APError.invalidResponse
        }
        
        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            break
        case 401:
            // Unauthorized - try to refresh token
            if retryCount > 0 && !endpoint.isRefreshToken {
                try await refreshAuthToken()
                return try await self.request(endpoint, body: body, retryCount: retryCount - 1)
            }
            throw APError.unauthorized
        case 403:
            throw APError.forbidden
        case 404:
            throw APError.notFound
        case 500...599:
            let errorMessage = String(data: data, encoding: .utf8)
            throw APError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        default:
            throw APError.invalidResponse
        }
        
        // Decode response
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw APError.decodingError(error)
        }
    }
    
    /// Performs a request that doesn't return data (e.g., DELETE)
    func requestVoid(
        _ endpoint: APIEndpoint,
        body: Encodable? = nil
    ) async throws {
        let _: EmptyResponse = try await request(endpoint, body: body)
    }
    
    // MARK: - Token Refresh
    
    private func refreshAuthToken() async throws {
        guard let refreshToken = refreshToken else {
            throw APError.unauthorized
        }
        
        struct RefreshRequest: Codable {
            let refreshToken: String
        }
        
        struct RefreshResponse: Codable {
            let token: String
            let refreshToken: String
        }
        
        let response: RefreshResponse = try await request(
            .refreshToken,
            body: RefreshRequest(refreshToken: refreshToken)
        )
        
        setAuthToken(response.token)
        setRefreshToken(response.refreshToken)
    }
    
    // MARK: - Mock Data (For Development)
    
    private func mockRequest<T: Codable>(
        _ endpoint: APIEndpoint,
        body: Encodable?
    ) async throws -> T {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return mock data based on endpoint
        switch endpoint {
        case .login:
            let mockResponse = AuthResponse(
                user: User(
                    id: UUID().uuidString,
                    name: "Demo User",
                    email: "demo@example.com",
                    userType: .rider
                ),
                token: "mock_jwt_token_\(UUID().uuidString)",
                refreshToken: "mock_refresh_token_\(UUID().uuidString)"
            )
            return try forceCast(mockResponse)
            
        case .register:
            let mockResponse = AuthResponse(
                user: User(
                    id: UUID().uuidString,
                    name: "New User",
                    email: "new@example.com",
                    userType: .rider
                ),
                token: "mock_jwt_token_\(UUID().uuidString)",
                refreshToken: "mock_refresh_token_\(UUID().uuidString)"
            )
            return try forceCast(mockResponse)
            
        case .getAvailableRides:
            let mockRides = [
                Ride(
                    riderId: "rider1",
                    pickupLocation: Location(latitude: 12.9352, longitude: 77.6245, address: "Koramangala, Bengaluru"),
                    dropoffLocation: Location(latitude: 12.9698, longitude: 77.7500, address: "Whitefield, Bengaluru"),
                    fare: 285.0
                ),
                Ride(
                    riderId: "rider2",
                    pickupLocation: Location(latitude: 12.9857, longitude: 77.5533, address: "Malleshwaram, Bengaluru"),
                    dropoffLocation: Location(latitude: 12.9271, longitude: 77.6271, address: "Indiranagar, Bengaluru"),
                    fare: 195.0
                )
            ]
            return try forceCast(mockRides)
            
        case .getRideHistory:
            let mockHistory: [Ride] = []
            return try forceCast(mockHistory)
            
        case .requestRide:
            // Parse body to create ride
            if let rideRequest = body as? RideRequest {
                let ride = Ride(
                    riderId: rideRequest.riderId,
                    pickupLocation: rideRequest.pickupLocation,
                    dropoffLocation: rideRequest.dropoffLocation,
                    fare: rideRequest.fare
                )
                return try forceCast(ride)
            }
            throw APError.invalidData
            
        case .getMessages:
            let mockMessages: [Message] = []
            return try forceCast(mockMessages)
            
        case .logout:
            return try forceCast(EmptyResponse())
            
        default:
            // For unimplemented endpoints, return empty response
            return try forceCast(EmptyResponse())
        }
    }
    
    /// Helper to force cast mock responses
    private func forceCast<T: Codable>(_ value: some Codable) throws -> T {
        // Encode and decode to ensure proper type conversion
        let data = try encoder.encode(value)
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Logging
    
    private func logRequest(_ request: URLRequest) {
        print("🌐 REQUEST: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "Unknown URL")")
        if let headers = request.allHTTPHeaderFields {
            print("📋 Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            let status = httpResponse.statusCode
            let emoji = (200...299).contains(status) ? "✅" : "❌"
            print("\(emoji) RESPONSE: \(status) \(response.url?.absoluteString ?? "")")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Data: \(responseString.prefix(500))")
        }
    }
}

// MARK: - Helper Types

/// Empty response for endpoints that don't return data
struct EmptyResponse: Codable {}

/// Type-erased wrapper for Encodable values
struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init(_ value: Encodable) {
        self.encode = value.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}

// MARK: - Request Models

/// Request model for creating a ride
struct RideRequest: Codable {
    let riderId: String
    let pickupLocation: Location
    let dropoffLocation: Location
    let fare: Double
}

/// Response model for authentication
struct AuthResponse: Codable {
    let user: User
    let token: String
    let refreshToken: String
}
