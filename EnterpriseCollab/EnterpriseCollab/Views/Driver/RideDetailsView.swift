import SwiftUI

struct RideDetailsView: View {
    let ride: Ride
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Fare Display
                VStack {
                    Text("Ride Fare")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("$\(ride.fare, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding()
                
                // Route Details
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("Pickup")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(ride.pickupLocation.address)
                                .font(.body)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 30)
                        .padding(.leading, 8)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        VStack(alignment: .leading) {
                            Text("Dropoff")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(ride.dropoffLocation.address)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Rider Info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                        Text("Rider")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("John Doe")
                            .font(.headline)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("4.8")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                
                Spacer()
                
                // Accept Button
                Button(action: {
                    if let driverId = authViewModel.currentUser?.id {
                        rideViewModel.acceptRide(ride, driverId: driverId)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Accept Ride")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Ride Details")
            .navigationBarItems(
                trailing: Button("Decline") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            )
        }
    }
}
