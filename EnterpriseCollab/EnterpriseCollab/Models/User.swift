import Foundation

enum UserType: String, CaseIterable, Codable {
    case rider = "Rider"
    case driver = "Driver"
}

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let userType: UserType
    var profileImageUrl: String?
    var rating: Double = 4.5
    
    init(id: String = UUID().uuidString, name: String, email: String, userType: UserType) {
        self.id = id
        self.name = name
        self.email = email
        self.userType = userType
    }
}
