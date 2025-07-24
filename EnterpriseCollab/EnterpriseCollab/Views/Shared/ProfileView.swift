
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var rideViewModel: RideViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(authViewModel.currentUser?.name ?? "User")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(authViewModel.currentUser?.rating ?? 0.0, specifier: "%.1f")")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    
                    // Stats
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(rideViewModel.rideHistory.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Total Rides")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("4.8")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Rating")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("2")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Years")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Menu Items
                    VStack(spacing: 15) {
                        ProfileMenuItem(
                            icon: "clock.arrow.circlepath",
                            title: "Ride History",
                            action: {}
                        )
                        
                        ProfileMenuItem(
                            icon: "creditcard",
                            title: "Payment Methods",
                            action: {}
                        )
                        
                        ProfileMenuItem(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            action: {}
                        )
                        
                        ProfileMenuItem(
                            icon: "gearshape",
                            title: "Settings",
                            action: {}
                        )
                    }
                    .padding(.horizontal)
                    
                    // Logout Button
                    Button(action: {
                        authViewModel.logout()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 30)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
