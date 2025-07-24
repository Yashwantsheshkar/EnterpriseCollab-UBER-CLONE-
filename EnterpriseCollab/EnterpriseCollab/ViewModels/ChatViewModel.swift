import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentChat: [Message] = []
    
    func sendMessage(from senderId: String, to receiverId: String, content: String) {
        let message = Message(
            senderId: senderId,
            receiverId: receiverId,
            content: content
        )
        messages.append(message)
        loadChat(between: senderId, and: receiverId)
    }
    
    func loadChat(between user1: String, and user2: String) {
        currentChat = messages.filter { message in
            (message.senderId == user1 && message.receiverId == user2) ||
            (message.senderId == user2 && message.receiverId == user1)
        }.sorted { $0.timestamp < $1.timestamp }
    }
}
