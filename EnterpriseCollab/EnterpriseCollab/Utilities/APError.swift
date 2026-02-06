import Foundation

/// Custom error types for the application
/// Provides detailed error handling and user-friendly messages
enum APError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case decodingError(Error)
    case encodingError(Error)
    case noInternetConnection
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .invalidData:
            return "The data received from server was invalid."
        case .unauthorized:
            return "Your session has expired. Please login again."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let statusCode, let message):
            return message ?? "Server error occurred (Code: \(statusCode))."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to process server response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to prepare request: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "The request timed out. Please try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
    
    /// User-friendly title for the error
    var title: String {
        switch self {
        case .unauthorized:
            return "Session Expired"
        case .noInternetConnection:
            return "No Connection"
        case .timeout:
            return "Request Timeout"
        case .serverError:
            return "Server Error"
        default:
            return "Error"
        }
    }
    
    /// Determines if the error is recoverable (can retry)
    var isRecoverable: Bool {
        switch self {
        case .networkError, .noInternetConnection, .timeout, .serverError:
            return true
        default:
            return false
        }
    }
}
