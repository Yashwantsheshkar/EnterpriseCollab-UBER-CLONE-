import SwiftUI

struct PaymentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPayment = "Apple Pay"
    
    let paymentMethods = [
        ("Apple Pay", "applelogo"),
        ("Credit Card", "creditcard.fill"),
        ("PayPal", "p.circle.fill"),
        ("Cash", "banknote.fill")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Payment Method")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                ForEach(paymentMethods, id: \.0) { method, icon in
                    PaymentMethodRow(
                        name: method,
                        icon: icon,
                        isSelected: selectedPayment == method
                    ) {
                        selectedPayment = method
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Process payment selection
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm Payment Method")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Payment")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PaymentMethodRow: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 30)
                
                Text(name)
                    .font(.body)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(.black)
        .padding(.horizontal)
    }
}
