import SwiftUI

struct DriverHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var isOnline = false
    @State private var showProfile = false
    @State private var showChat = false
    @State private var selectedRide: Ride?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                DriverMapView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Top Bar
                    HStack {
                        Button(action: { showProfile = true }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                        }
                        
                        Spacer()
                        
                        // Online/Offline Toggle
                        Toggle(isOn: $isOnline) {
                            Text(isOnline ? "Online" : "Offline")
                                .fontWeight(.bold)
                        }
                        .toggleStyle(OnlineToggleStyle())
                        
                        Spacer()
                        
                        if rideViewModel.currentRide != nil {
                            Button(action: { showChat = true }) {
                                Image(systemName: "message.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(Color.white))
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Bottom Section
                    if let currentRide = rideViewModel.currentRide {
                        CurrentRideCard(ride: currentRide)
                            .padding()
                    } else if isOnline {
                        AvailableRidesView(selectedRide: $selectedRide)
                            .padding()
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showChat) {
                if let currentUser = authViewModel.currentUser,
                   let ride = rideViewModel.currentRide {
                    ChatView(
                        currentUserId: currentUser.id,
                        otherUserId: ride.riderId,
                        otherUserName: "Rider"
                    )
                }
            }
            .sheet(item: $selectedRide) { ride in
                RideDetailsView(ride: ride)
            }
        }
    }
}

struct OnlineToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .fill(configuration.isOn ? Color.green : Color.gray)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 2)
    }
}

struct CurrentRideCard: View {
    let ride: Ride
    @EnvironmentObject var rideViewModel: RideViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(ride.status.rawValue)
                    .font(.headline)
                Spacer()
                Text("₹\(ride.fare, specifier: "%.0f")")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Label(ride.pickupLocation.address, systemImage: "circle.fill")
                    .foregroundColor(.green)
                Label(ride.dropoffLocation.address, systemImage: "mappin.circle.fill")
                    .foregroundColor(.red)
            }
            
            if ride.status == .accepted {
                Button(action: { rideViewModel.startRide() }) {
                    Text("Start Ride")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            } else if ride.status == .inProgress {
                Button(action: { rideViewModel.completeRide() }) {
                    Text("Complete Ride")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct AvailableRidesView: View {
    @EnvironmentObject var rideViewModel: RideViewModel
    @Binding var selectedRide: Ride?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Available Rides")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(rideViewModel.availableRides) { ride in
                        RideCard(ride: ride) {
                            selectedRide = ride
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
