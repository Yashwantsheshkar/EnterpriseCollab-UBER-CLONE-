import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [String: [Message]] = [:] // Keyed by rideId
    @Published var currentChat: [Message] = []
    @Published var currentRideId: String?
    
    /// Sets the current ride for chat context
    func setCurrentRide(_ rideId: String) {
        currentRideId = rideId
        loadChatForRide(rideId)
    }
    
    /// Sends a message for the current ride
    func sendMessage(from senderId: String, to receiverId: String, content: String) {
        guard let rideId = currentRideId else {
            print("No active ride for chat")
            return
        }
        
        let message = Message(
            rideId: rideId,
            senderId: senderId,
            receiverId: receiverId,
            content: content
        )
        
        // Add to messages dictionary
        if messages[rideId] == nil {
            messages[rideId] = []
        }
        messages[rideId]?.append(message)
        
        // Update current chat view
        loadChatForRide(rideId)
    }
    
    /// Loads chat messages for a specific ride
    func loadChatForRide(_ rideId: String) {
        currentChat = (messages[rideId] ?? []).sorted { $0.timestamp < $1.timestamp }
    }
    
    /// Legacy method for compatibility - now uses currentRideId
    func loadChat(between user1: String, and user2: String) {
        guard let rideId = currentRideId else { return }
        loadChatForRide(rideId)
    }
    
    /// Clears chat when ride completes
    func clearCurrentChat() {
        currentRideId = nil
        currentChat = []
    }
}
