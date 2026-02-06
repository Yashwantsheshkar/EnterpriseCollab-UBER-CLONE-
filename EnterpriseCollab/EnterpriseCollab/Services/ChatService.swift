import Foundation

/// Service class for handling all chat-related API calls
final class ChatService {
    
    // MARK: - Singleton
    
    static let shared = ChatService()
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Chat Methods
    
    /// Gets all messages for a specific ride
    /// - Parameter rideId: ID of the ride
    /// - Returns: Array of Message objects
    func getMessages(rideId: String) async throws -> [Message] {
        return try await networkManager.request(.getMessages(rideId: rideId))
    }
    
    /// Sends a message in a ride chat
    /// - Parameters:
    ///   - rideId: ID of the ride
    ///   - senderId: ID of the sender
    ///   - receiverId: ID of the receiver
    ///   - content: Message content
    /// - Returns: Created Message object
    func sendMessage(
        rideId: String,
        senderId: String,
        receiverId: String,
        content: String
    ) async throws -> Message {
        struct MessageRequest: Codable {
            let senderId: String
            let receiverId: String
            let content: String
        }
        
        let request = MessageRequest(
            senderId: senderId,
            receiverId: receiverId,
            content: content
        )
        
        return try await networkManager.request(.sendMessage(rideId: rideId), body: request)
    }
}
