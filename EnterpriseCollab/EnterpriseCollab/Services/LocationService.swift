import Foundation
import CoreLocation
import Combine

/// Service for managing live location sharing between rider and driver
final class LocationService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = LocationService()
    
    // MARK: - Published Properties
    
    /// The other user's location (driver sees rider, rider sees driver)
    @Published var otherUserLocation: CLLocationCoordinate2D?
    
    /// Whether location sharing is active
    @Published var isTrackingActive = false
    
    /// Current ride being tracked
    @Published var activeRideId: String?
    
    // MARK: - Private Properties
    
    private var locationUpdateTimer: Timer?
    private let updateInterval: TimeInterval = 3.0 // Update every 3 seconds
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Starts tracking location for a ride
    /// - Parameters:
    ///   - rideId: ID of the active ride
    ///   - userLocation: Current user's location to share
    func startTracking(rideId: String, userLocation: CLLocationCoordinate2D) {
        activeRideId = rideId
        isTrackingActive = true
        
        // Start periodic location updates
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.simulateOtherUserLocation(userLocation: userLocation)
        }
        
        // Initial update
        simulateOtherUserLocation(userLocation: userLocation)
    }
    
    /// Stops tracking location
    func stopTracking() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        isTrackingActive = false
        activeRideId = nil
        otherUserLocation = nil
    }
    
    /// Updates the shared location (called when user location changes)
    /// - Parameter location: New user location
    func updateMyLocation(_ location: CLLocationCoordinate2D) {
        guard isTrackingActive else { return }
        
        // In a real app, this would send to backend via WebSocket or API
        // For now, we simulate movement
        Task {
            do {
                try await RideService.shared.updateDriverLocation(location)
            } catch {
                print("Failed to update location: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Simulates the other user's location for demo purposes
    /// In production, this would receive updates from WebSocket
    private func simulateOtherUserLocation(userLocation: CLLocationCoordinate2D) {
        // Simulate other user being nearby (within ~500m)
        // In production, this would come from the backend
        let latOffset = Double.random(in: -0.003...0.003)
        let lonOffset = Double.random(in: -0.003...0.003)
        
        DispatchQueue.main.async {
            self.otherUserLocation = CLLocationCoordinate2D(
                latitude: userLocation.latitude + latOffset,
                longitude: userLocation.longitude + lonOffset
            )
        }
    }
    
    /// Calculates distance to other user
    /// - Returns: Distance in meters, or nil if not tracking
    func distanceToOtherUser(from myLocation: CLLocationCoordinate2D) -> Double? {
        guard let otherLocation = otherUserLocation else { return nil }
        
        let myLoc = CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude)
        let otherLoc = CLLocation(latitude: otherLocation.latitude, longitude: otherLocation.longitude)
        
        return myLoc.distance(from: otherLoc)
    }
    
    /// Estimates time to reach other user
    /// - Returns: Estimated time in minutes
    func estimatedTimeToOtherUser(from myLocation: CLLocationCoordinate2D) -> Int? {
        guard let distance = distanceToOtherUser(from: myLocation) else { return nil }
        
        // Assume average speed of 20 km/h in city traffic
        let speedMetersPerMinute = 20.0 * 1000.0 / 60.0
        let minutes = distance / speedMetersPerMinute
        
        return max(1, Int(minutes.rounded()))
    }
}
