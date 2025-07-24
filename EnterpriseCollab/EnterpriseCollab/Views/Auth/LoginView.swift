import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = "demo@example.com"
    @State private var password = "password"
    @State private var selectedUserType: UserType = .rider
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "car.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Enterprise Collab")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // User Type Selection
                Picker("User Type", selection: $selectedUserType) {
                    ForEach(UserType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Login Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        authViewModel.login(
                            email: email,
                            password: password,
                            userType: selectedUserType
                        )
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Demo Info
                Text("Demo Mode: Use any email/password")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
