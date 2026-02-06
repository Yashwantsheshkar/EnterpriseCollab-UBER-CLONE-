import Foundation
import CoreLocation
import MapKit
import Combine

class LocationViewModel: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userAddress: String = "Getting location..."
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching = false
    
    /// Other user's location (driver sees rider location, rider sees driver location)
    @Published var otherUserLocation: CLLocationCoordinate2D?
    
    /// Estimated time to other user in minutes
    @Published var etaToOtherUser: Int?
    
    /// Whether actively tracking for a ride
    @Published var isTrackingRide = false
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set default location (Bengaluru, India)
        userLocation = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
        
        // Subscribe to LocationService updates
        locationService.$otherUserLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.otherUserLocation = location
                self?.updateETA()
            }
            .store(in: &cancellables)
        
        locationService.$isTrackingActive
            .receive(on: DispatchQueue.main)
            .assign(to: &$isTrackingRide)
    }
    
    // MARK: - Ride Tracking
    
    /// Starts tracking for an active ride
    func startRideTracking(rideId: String) {
        guard let userLoc = userLocation else { return }
        locationService.startTracking(rideId: rideId, userLocation: userLoc)
    }
    
    /// Stops tracking when ride completes
    func stopRideTracking() {
        locationService.stopTracking()
        otherUserLocation = nil
        etaToOtherUser = nil
    }
    
    private func updateETA() {
        guard let userLoc = userLocation else { return }
        etaToOtherUser = locationService.estimatedTimeToOtherUser(from: userLoc)
    }
    
    // MARK: - Search
    
    func searchLocation(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Set search region around Bengaluru
        if let userLocation = userLocation {
            request.region = MKCoordinateRegion(
                center: userLocation,
                latitudinalMeters: 50000,
                longitudinalMeters: 50000
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                if let response = response {
                    self?.searchResults = response.mapItems
                } else {
                    self?.searchResults = []
                }
            }
        }
    }
    
    func reverseGeocode(location: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let placemark = placemarks?.first {
                let address = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea
                ].compactMap { $0 }.joined(separator: ", ")
                completion(address)
            } else {
                completion("Unknown Location")
            }
        }
    }
    
    func getCurrentLocationAddress() {
        guard let location = userLocation else { return }
        reverseGeocode(location: location) { [weak self] address in
            DispatchQueue.main.async {
                self?.userAddress = address
            }
        }
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        getCurrentLocationAddress()
        
        // Update location service if tracking is active
        if locationService.isTrackingActive {
            locationService.updateMyLocation(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
