import SwiftUI

struct RideCard: View {
    let ride: Ride
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("₹\(ride.fare, specifier: "%.0f")")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("5 min away")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                HStack(spacing: 15) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.green)
                    Text(ride.pickupLocation.address)
                        .font(.footnote)
                        .lineLimit(1)
                }
                
                HStack(spacing: 15) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(ride.dropoffLocation.address)
                        .font(.footnote)
                        .lineLimit(1)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .foregroundColor(.black)
        .padding(.horizontal)
    }
}
