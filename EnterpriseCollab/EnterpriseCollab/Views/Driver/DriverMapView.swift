import SwiftUI
import MapKit

struct DriverMapView: View {
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
        .onReceive(locationViewModel.$userLocation.compactMap { $0 }) { newLocation in
            withAnimation {
                region.center = newLocation
            }
        }
    }
    
    var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        
        // Show current ride locations
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
        }
        
        // Show available rides
        for (index, ride) in rideViewModel.availableRides.enumerated() {
            items.append(MapAnnotationItem(
                id: "ride-\(ride.id)",
                coordinate: ride.pickupLocation.coordinate,
                type: .pickup,
                label: "₹\(Int(ride.fare))",
                showLabel: true
            ))
        }
        
        return items
    }
}
