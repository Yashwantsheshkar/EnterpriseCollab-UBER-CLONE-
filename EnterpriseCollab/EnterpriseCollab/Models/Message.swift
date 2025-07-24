import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         senderId: String,
         receiverId: String,
         content: String) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.timestamp = Date()
    }
}
