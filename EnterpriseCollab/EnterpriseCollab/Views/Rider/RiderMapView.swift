import SwiftUI
import MapKit

struct RiderMapView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Bengaluru
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) { item in
            MapAnnotation(coordinate: item.coordinate) {
                VStack {
                    Image(systemName: item.type.icon)
                        .font(.title2)
                        .foregroundColor(item.type.color)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                        )
                        .overlay(
                            Circle()
                                .stroke(item.type.color, lineWidth: 2)
                                .frame(width: 35, height: 35)
                        )
                    
                    if item.showLabel {
                        Text(item.label)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .onAppear {
            if let userLocation = locationViewModel.userLocation {
                region.center = userLocation
            }
        }
        .onReceive(locationViewModel.$userLocation) { newLocation in
            if let location = newLocation {
                withAnimation {
                    region.center = location
                }
            }
        }
    }
    
    var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        
        if let ride = rideViewModel.currentRide {
            items.append(MapAnnotationItem(
                id: "pickup",
                coordinate: ride.pickupLocation.coordinate,
                type: .pickup,
                label: "Pickup",
                showLabel: true
            ))
            items.append(MapAnnotationItem(
                id: "dropoff",
                coordinate: ride.dropoffLocation.coordinate,
                type: .dropoff,
                label: "Dropoff",
                showLabel: true
            ))
            
            // Show driver location if ride is accepted
            if ride.status == .accepted || ride.status == .inProgress {
                // Simulate driver location
                let driverLat = ride.pickupLocation.latitude - 0.005
                let driverLon = ride.pickupLocation.longitude + 0.005
                items.append(MapAnnotationItem(
                    id: "driver",
                    coordinate: CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon),
                    type: .driver,
                    label: "Driver",
                    showLabel: true
                ))
            }
        }
        
        return items
    }
}

struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    let label: String
    let showLabel: Bool
    
    init(id: String, coordinate: CLLocationCoordinate2D, type: AnnotationType, label: String = "", showLabel: Bool = false) {
        self.id = id
        self.coordinate = coordinate
        self.type = type
        self.label = label
        self.showLabel = showLabel
    }
    
    enum AnnotationType {
        case pickup, dropoff, driver
        
        var icon: String {
            switch self {
            case .pickup: return "circle.fill"
            case .dropoff: return "mappin.circle.fill"
            case .driver: return "car.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .pickup: return .green
            case .dropoff: return .red
            case .driver: return .blue
            }
        }
    }
}
