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
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set default location (Bengaluru, India)
        userLocation = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
    }
    
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
