import SwiftUI
import MapKit

struct RideRequestView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    
    @State private var pickupAddress = ""
    @State private var dropoffAddress = ""
    @State private var showingPayment = false
    @State private var showingPickupSearch = false
    @State private var showingDropoffSearch = false
    @State private var selectedPickup: Location?
    @State private var selectedDropoff: Location?
    @State private var showFareBreakdown = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                locationInputSection
                fareEstimateSection
                Spacer()
                requestButton
                paymentMethodButton
            }
            .navigationTitle("Request Ride")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingPickupSearch) {
                LocationSearchView(
                    selectedLocation: $selectedPickup,
                    selectedAddress: $pickupAddress,
                    isPresented: $showingPickupSearch,
                    title: "Set Pickup Location",
                    useCurrentLocation: true
                )
            }
            .sheet(isPresented: $showingDropoffSearch) {
                LocationSearchView(
                    selectedLocation: $selectedDropoff,
                    selectedAddress: $dropoffAddress,
                    isPresented: $showingDropoffSearch,
                    title: "Set Dropoff Location",
                    useCurrentLocation: false
                )
            }
            .sheet(isPresented: $showingPayment) {
                PaymentView()
            }
            .sheet(isPresented: $showFareBreakdown) {
                FareBreakdownView()
            }
            .onAppear {
                // Delay to avoid publishing during view updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    useCurrentLocation()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var locationInputSection: some View {
        VStack(spacing: 15) {
            // Pickup Location
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                VStack(alignment: .leading) {
                    Text("Pickup")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button(action: { showingPickupSearch = true }) {
                        Text(pickupAddress.isEmpty ? "Current Location" : pickupAddress)
                            .foregroundColor(pickupAddress.isEmpty ? .blue : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if !pickupAddress.isEmpty {
                    Button(action: {
                        pickupAddress = ""
                        selectedPickup = nil
                        useCurrentLocation()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Dropoff Location
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                
                VStack(alignment: .leading) {
                    Text("Dropoff")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button(action: { showingDropoffSearch = true }) {
                        Text(dropoffAddress.isEmpty ? "Where to?" : dropoffAddress)
                            .foregroundColor(dropoffAddress.isEmpty ? .gray : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if !dropoffAddress.isEmpty {
                    Button(action: {
                        dropoffAddress = ""
                        selectedDropoff = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var fareEstimateSection: some View {
        if let pickup = selectedPickup ?? getCurrentLocationAsLocation(),
           let dropoff = selectedDropoff {
            VStack(spacing: 15) {
                HStack {
                    Text("Estimated Fare")
                        .font(.headline)
                    Spacer()
                    Button(action: { showFareBreakdown = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
                
                Text("₹\(rideViewModel.calculateAdvancedFare(from: pickup, to: dropoff), specifier: "%.0f")")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
                
                if let breakdown = rideViewModel.fareBreakdown {
                    HStack {
                        Spacer()
                        Label("\(calculateRawDistance(from: pickup, to: dropoff), specifier: "%.1f") km", systemImage: "location")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
    
    private var requestButton: some View {
        Button(action: requestRide) {
            Text("Request Ride")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding()
        .disabled(selectedDropoff == nil)
    }
    
    private var paymentMethodButton: some View {
        Button(action: { showingPayment = true }) {
            HStack {
                Image(systemName: "creditcard.fill")
                Text("Payment Method")
                Spacer()
                Text("Apple Pay")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    
    private func useCurrentLocation() {
        guard let userLocation = locationViewModel.userLocation else { return }
        
        // Use a small delay to avoid publishing during view updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedPickup = Location(
                coordinate: userLocation,
                address: locationViewModel.userAddress
            )
            pickupAddress = locationViewModel.userAddress
        }
    }
    
    private func getCurrentLocationAsLocation() -> Location? {
        guard let userLocation = locationViewModel.userLocation else { return nil }
        return Location(
            coordinate: userLocation,
            address: locationViewModel.userAddress
        )
    }
    
    private func calculateRawDistance(from pickup: Location, to dropoff: Location) -> Double {
        let fromLocation = CLLocation(latitude: pickup.latitude, longitude: pickup.longitude)
        let toLocation = CLLocation(latitude: dropoff.latitude, longitude: dropoff.longitude)
        return fromLocation.distance(from: toLocation) / 1000
    }
    
    private func requestRide() {
        guard let userId = authViewModel.currentUser?.id,
              let pickup = selectedPickup ?? getCurrentLocationAsLocation(),
              let dropoff = selectedDropoff else { return }
        
        rideViewModel.requestRide(
            pickup: pickup,
            dropoff: dropoff,
            riderId: userId
        )
        presentationMode.wrappedValue.dismiss()
    }
}

struct LocationSearchView: View {
    @Binding var selectedLocation: Location?
    @Binding var selectedAddress: String
    @Binding var isPresented: Bool
    let title: String
    let useCurrentLocation: Bool
    
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State private var searchText = ""
    @State private var debounceTimer: Timer?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search location...", text: $searchText)
                        .onChange(of: searchText) { newValue in
                            // Debounce the search
                            debounceTimer?.invalidate()
                            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                if !newValue.isEmpty {
                                    locationViewModel.searchLocation(query: newValue)
                                }
                            }
                        }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if useCurrentLocation {
                    Button(action: {
                        if let userLocation = locationViewModel.userLocation {
                            selectedLocation = Location(
                                coordinate: userLocation,
                                address: locationViewModel.userAddress
                            )
                            selectedAddress = locationViewModel.userAddress
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Use Current Location")
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Search Results
                if locationViewModel.isSearching {
                    ProgressView()
                        .padding()
                    Spacer()
                } else if searchText.isEmpty {
                    Spacer()
                } else {
                    List(locationViewModel.searchResults, id: \.self) { mapItem in
                        Button(action: {
                            selectedLocation = Location(
                                coordinate: mapItem.placemark.coordinate,
                                address: mapItem.name ?? "Unknown"
                            )
                            selectedAddress = mapItem.name ?? "Unknown"
                            isPresented = false
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mapItem.name ?? "Unknown")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                if let address = mapItem.placemark.title {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(title)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
        .onDisappear {
            debounceTimer?.invalidate()
        }
    }
}

struct FareBreakdownView: View {
    @EnvironmentObject var rideViewModel: RideViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            if let breakdown = rideViewModel.fareBreakdown {
                List {
                    Section(header: Text("Fare Components")) {
                        HStack {
                            Text("Base Fare")
                            Spacer()
                            Text("₹\(breakdown.baseFare, specifier: "%.0f")")
                        }
                        
                        HStack {
                            Text("Distance Charge")
                            Spacer()
                            Text("₹\(breakdown.distanceCharge, specifier: "%.0f")")
                        }
                        
                        HStack {
                            Text("Time Charge")
                            Spacer()
                            Text("₹\(breakdown.timeCharge, specifier: "%.0f")")
                        }
                        
                        if breakdown.peakCharge > 0 {
                            HStack {
                                Text("Peak Hour Charge")
                                Spacer()
                                Text("₹\(breakdown.peakCharge, specifier: "%.0f")")
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if breakdown.nightCharge > 0 {
                            HStack {
                                Text("Night Charge")
                                Spacer()
                                Text("₹\(breakdown.nightCharge, specifier: "%.0f")")
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        if breakdown.surgeMultiplier > 1 {
                            HStack {
                                Text("Surge Pricing")
                                Spacer()
                                Text("\(breakdown.surgeMultiplier, specifier: "%.1f")x")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("Total Fare")
                                .font(.headline)
                            Spacer()
                            Text("₹\(breakdown.totalFare, specifier: "%.0f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .navigationTitle("Fare Breakdown")
                .navigationBarItems(
                    trailing: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
}
