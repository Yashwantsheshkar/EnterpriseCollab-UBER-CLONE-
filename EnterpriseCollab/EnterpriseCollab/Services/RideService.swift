import Foundation
import CoreLocation

/// Service class for handling all ride-related API calls
final class RideService {
    
    // MARK: - Singleton
    
    static let shared = RideService()
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Ride Request Methods
    
    /// Requests a new ride
    /// - Parameters:
    ///   - pickup: Pickup location
    ///   - dropoff: Dropoff location
    ///   - riderId: ID of the rider
    ///   - fare: Calculated fare amount
    /// - Returns: Created Ride object
    func requestRide(
        pickup: Location,
        dropoff: Location,
        riderId: String,
        fare: Double
    ) async throws -> Ride {
        let request = RideRequest(
            riderId: riderId,
            pickupLocation: pickup,
            dropoffLocation: dropoff,
            fare: fare
        )
        
        return try await networkManager.request(.requestRide, body: request)
    }
    
    /// Gets a specific ride by ID
    /// - Parameter rideId: Ride ID
    /// - Returns: Ride object
    func getRide(id: String) async throws -> Ride {
        return try await networkManager.request(.getRide(id: id))
    }
    
    /// Gets all available rides for drivers
    /// - Returns: Array of available Ride objects
    func getAvailableRides() async throws -> [Ride] {
        return try await networkManager.request(.getAvailableRides)
    }
    
    /// Gets the ride history for the current user
    /// - Returns: Array of past Ride objects
    func getRideHistory() async throws -> [Ride] {
        return try await networkManager.request(.getRideHistory)
    }
    
    // MARK: - Ride Status Methods
    
    /// Accepts a ride request (driver)
    /// - Parameters:
    ///   - rideId: ID of the ride to accept
    ///   - driverId: ID of the accepting driver
    /// - Returns: Updated Ride object
    func acceptRide(rideId: String, driverId: String) async throws -> Ride {
        struct AcceptRequest: Codable {
            let driverId: String
        }
        
        return try await networkManager.request(
            .acceptRide(rideId: rideId),
            body: AcceptRequest(driverId: driverId)
        )
    }
    
    /// Declines a ride request (driver)
    /// - Parameter rideId: ID of the ride to decline
    func declineRide(rideId: String) async throws {
        try await networkManager.requestVoid(.declineRide(rideId: rideId))
    }
    
    /// Starts an accepted ride (driver)
    /// - Parameter rideId: ID of the ride to start
    /// - Returns: Updated Ride object
    func startRide(rideId: String) async throws -> Ride {
        return try await networkManager.request(.startRide(rideId: rideId))
    }
    
    /// Completes a ride (driver)
    /// - Parameter rideId: ID of the ride to complete
    /// - Returns: Updated Ride object with final details
    func completeRide(rideId: String) async throws -> Ride {
        return try await networkManager.request(.completeRide(rideId: rideId))
    }
    
    /// Cancels a ride (rider or driver)
    /// - Parameters:
    ///   - rideId: ID of the ride to cancel
    ///   - reason: Optional cancellation reason
    func cancelRide(rideId: String, reason: String? = nil) async throws {
        struct CancelRequest: Codable {
            let reason: String?
        }
        
        try await networkManager.requestVoid(
            .cancelRide(rideId: rideId),
            body: CancelRequest(reason: reason)
        )
    }
    
    /// Rates a completed ride
    /// - Parameters:
    ///   - rideId: ID of the ride to rate
    ///   - rating: Rating value (1-5)
    ///   - comment: Optional feedback comment
    func rateRide(rideId: String, rating: Int, comment: String? = nil) async throws {
        struct RateRequest: Codable {
            let rating: Int
            let comment: String?
        }
        
        try await networkManager.requestVoid(
            .rateRide(rideId: rideId),
            body: RateRequest(rating: rating, comment: comment)
        )
    }
    
    // MARK: - Driver Methods
    
    /// Sets driver status to online
    /// - Parameter location: Current driver location
    func goOnline(location: CLLocationCoordinate2D) async throws {
        struct OnlineRequest: Codable {
            let latitude: Double
            let longitude: Double
        }
        
        try await networkManager.requestVoid(
            .driverGoOnline,
            body: OnlineRequest(latitude: location.latitude, longitude: location.longitude)
        )
    }
    
    /// Sets driver status to offline
    func goOffline() async throws {
        try await networkManager.requestVoid(.driverGoOffline)
    }
    
    /// Gets driver statistics
    /// - Returns: DriverStats object
    func getDriverStats() async throws -> DriverStats {
        return try await networkManager.request(.getDriverStats)
    }
    
    /// Gets driver earnings
    /// - Parameter period: Time period (day, week, month)
    /// - Returns: Earnings object
    func getEarnings(period: String = "week") async throws -> DriverEarnings {
        return try await networkManager.request(.getEarnings)
    }
    
    // MARK: - Location Updates
    
    /// Updates driver location to backend
    /// - Parameter location: Current location
    func updateDriverLocation(_ location: CLLocationCoordinate2D) async throws {
        struct LocationUpdate: Codable {
            let latitude: Double
            let longitude: Double
            let timestamp: Date
        }
        
        try await networkManager.requestVoid(
            .updateLocation,
            body: LocationUpdate(
                latitude: location.latitude,
                longitude: location.longitude,
                timestamp: Date()
            )
        )
    }
}

// MARK: - Supporting Models

/// Driver statistics model
struct DriverStats: Codable {
    let totalRides: Int
    let totalEarnings: Double
    let rating: Double
    let acceptanceRate: Double
    let cancellationRate: Double
}

/// Driver earnings model
struct DriverEarnings: Codable {
    let period: String
    let totalEarnings: Double
    let rideCount: Int
    let tips: Double
    let bonuses: Double
    let dailyBreakdown: [DailyEarning]?
}

/// Daily earning breakdown
struct DailyEarning: Codable {
    let date: Date
    let earnings: Double
    let rideCount: Int
}
