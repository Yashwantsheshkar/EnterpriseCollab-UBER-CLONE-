import SwiftUI

struct RiderHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @State private var showRideRequest = false
    @State private var showChat = false
    @State private var showProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                RiderMapView()
                    .edgesIgnoringSafeArea(.all)
                
                // Top Bar
                VStack {
                    HStack {
                        Button(action: { showProfile = true }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                        }
                        
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
                    
                    // Bottom Card
                    if let ride = rideViewModel.currentRide {
                        RideStatusCard(ride: ride)
                            .padding()
                    } else {
                        RequestRideButton(showRideRequest: $showRideRequest)
                            .padding()
                    }
                }
            }
            .sheet(isPresented: $showRideRequest) {
                RideRequestView()
            }
            .sheet(isPresented: $showChat) {
                if let currentUser = authViewModel.currentUser,
                   let ride = rideViewModel.currentRide,
                   let driverId = ride.driverId {
                    ChatView(
                        rideId: ride.id,
                        currentUserId: currentUser.id,
                        otherUserId: driverId,
                        otherUserName: "Your Driver"
                    )
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

struct RequestRideButton: View {
    @Binding var showRideRequest: Bool
    
    var body: some View {
        Button(action: { showRideRequest = true }) {
            HStack {
                Image(systemName: "location.fill")
                Text("Where to?")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .foregroundColor(.black)
    }
}

struct RideStatusCard: View {
    let ride: Ride
    @EnvironmentObject var rideViewModel: RideViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(ride.status.rawValue)
                    .font(.headline)
                    .foregroundColor(statusColor)
                Spacer()
                Text("₹\(ride.fare, specifier: "%.0f")")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Divider()
            
            if ride.status == .accepted || ride.status == .inProgress {
                HStack {
                    Image(systemName: "person.fill")
                    Text("Driver is on the way")
                    Spacer()
                    Text("5 min")
                        .foregroundColor(.gray)
                }
            }
            
            if ride.status != .completed && ride.status != .cancelled {
                Button(action: { rideViewModel.cancelRide() }) {
                    Text("Cancel Ride")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    var statusColor: Color {
        switch ride.status {
        case .requested: return .orange
        case .accepted: return .blue
        case .inProgress: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}
