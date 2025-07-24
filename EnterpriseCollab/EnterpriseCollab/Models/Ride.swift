import Foundation
import CoreLocation

enum RideStatus: String, CaseIterable, Codable {
    case requested = "Requested"
    case accepted = "Accepted"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct Ride: Identifiable, Codable {
    let id: String
    let riderId: String
    var driverId: String?
    let pickupLocation: Location
    let dropoffLocation: Location
    var status: RideStatus
    let fare: Double
    let requestTime: Date
    var acceptTime: Date?
    var startTime: Date?
    var endTime: Date?
    
    init(id: String = UUID().uuidString,
         riderId: String,
         pickupLocation: Location,
         dropoffLocation: Location,
         fare: Double) {
        self.id = id
        self.riderId = riderId
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.status = .requested
        self.fare = fare
        self.requestTime = Date()
    }
}
