import SwiftUI

/// Reusable alert model for presenting errors and notifications to users
struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
    
    init(title: String, message: String, dismissButtonTitle: String = "OK") {
        self.title = Text(title)
        self.message = Text(message)
        self.dismissButton = .default(Text(dismissButtonTitle))
    }
    
    init(title: Text, message: Text, dismissButton: Alert.Button) {
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
    }
}

/// Pre-defined alert contexts for common scenarios
struct AlertContext {
    
    // MARK: - Authentication Alerts
    
    static let invalidCredentials = AlertItem(
        title: "Invalid Credentials",
        message: "The email or password you entered is incorrect. Please try again."
    )
    
    static let invalidEmail = AlertItem(
        title: "Invalid Email",
        message: "Please enter a valid email address."
    )
    
    static let invalidPassword = AlertItem(
        title: "Invalid Password",
        message: "Password must be at least 6 characters long."
    )
    
    static let sessionExpired = AlertItem(
        title: "Session Expired",
        message: "Your session has expired. Please login again."
    )
    
    static let registrationFailed = AlertItem(
        title: "Registration Failed",
        message: "Unable to create your account. Please try again."
    )
    
    static let logoutFailed = AlertItem(
        title: "Logout Failed",
        message: "Unable to logout. Please try again."
    )
    
    // MARK: - Network Alerts
    
    static let networkError = AlertItem(
        title: "Network Error",
        message: "Unable to connect to the server. Please check your internet connection and try again."
    )
    
    static let serverError = AlertItem(
        title: "Server Error",
        message: "Something went wrong on our end. Please try again later."
    )
    
    static let timeout = AlertItem(
        title: "Request Timeout",
        message: "The request took too long. Please try again."
    )
    
    static let noInternet = AlertItem(
        title: "No Internet",
        message: "No internet connection detected. Please check your network settings."
    )
    
    // MARK: - Ride Alerts
    
    static let rideRequestFailed = AlertItem(
        title: "Request Failed",
        message: "Unable to request a ride. Please try again."
    )
    
    static let rideAcceptFailed = AlertItem(
        title: "Accept Failed",
        message: "Unable to accept the ride. It may have been taken by another driver."
    )
    
    static let rideCancelFailed = AlertItem(
        title: "Cancel Failed",
        message: "Unable to cancel the ride. Please try again."
    )
    
    static let noDriversAvailable = AlertItem(
        title: "No Drivers Available",
        message: "There are no drivers available in your area right now. Please try again later."
    )
    
    static let rideCompleted = AlertItem(
        title: "Ride Completed",
        message: "Your ride has been completed. Thank you for riding with us!"
    )
    
    // MARK: - Location Alerts
    
    static let locationPermissionDenied = AlertItem(
        title: "Location Access Required",
        message: "Please enable location access in Settings to use this app."
    )
    
    static let locationUnavailable = AlertItem(
        title: "Location Unavailable",
        message: "Unable to determine your current location. Please try again."
    )
    
    // MARK: - Chat Alerts
    
    static let messageSendFailed = AlertItem(
        title: "Message Failed",
        message: "Unable to send your message. Please try again."
    )
    
    static let chatConnectionLost = AlertItem(
        title: "Connection Lost",
        message: "Chat connection was lost. Reconnecting..."
    )
    
    // MARK: - Payment Alerts
    
    static let paymentFailed = AlertItem(
        title: "Payment Failed",
        message: "Unable to process payment. Please try a different payment method."
    )
    
    static let paymentMethodRequired = AlertItem(
        title: "Payment Required",
        message: "Please add a payment method to request a ride."
    )
    
    // MARK: - Generic Alerts
    
    static let genericError = AlertItem(
        title: "Error",
        message: "Something went wrong. Please try again."
    )
    
    static let operationSuccessful = AlertItem(
        title: "Success",
        message: "Operation completed successfully."
    )
    
    // MARK: - Helper Method
    
    /// Creates an AlertItem from an APError
    static func from(error: APError) -> AlertItem {
        AlertItem(title: error.title, message: error.errorDescription ?? "An error occurred.")
    }
}

// MARK: - View Extension for Alerts

extension View {
    /// Presents an alert when the given AlertItem binding has a value
    func alert(item: Binding<AlertItem?>) -> some View {
        self.alert(item: item) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
        }
    }
}
