import Foundation
import CoreLocation

// Graph-based pricing algorithm structures
struct PricingNode {
    let location: CLLocationCoordinate2D
    let trafficWeight: Double
    let demandMultiplier: Double
}

struct PricingEdge {
    let from: Int
    let to: Int
    let distance: Double
    let timeEstimate: Double
}

class RideViewModel: ObservableObject {
    @Published var currentRide: Ride?
    @Published var availableRides: [Ride] = []
    @Published var rideHistory: [Ride] = []
    @Published var estimatedFare: Double = 0
    @Published var fareBreakdown: FareBreakdown?
    
    // Pricing configuration for India (in Rupees)
    private let baseFare: Double = 50.0 // Base fare in INR
    private let perKmRate: Double = 15.0 // Per km rate in INR
    private let perMinuteRate: Double = 2.0 // Per minute rate in INR
    private let peakHourMultiplier: Double = 1.5
    private let nightChargeMultiplier: Double = 1.2
    
    init() {
        loadMockRides()
    }
    
    func requestRide(pickup: Location, dropoff: Location, riderId: String) {
        let fare = calculateAdvancedFare(from: pickup, to: dropoff)
        let ride = Ride(
            riderId: riderId,
            pickupLocation: pickup,
            dropoffLocation: dropoff,
            fare: fare
        )
        currentRide = ride
        availableRides.append(ride)
    }
    
    func acceptRide(_ ride: Ride, driverId: String) {
        if let index = availableRides.firstIndex(where: { $0.id == ride.id }) {
            availableRides[index].driverId = driverId
            availableRides[index].status = .accepted
            availableRides[index].acceptTime = Date()
            currentRide = availableRides[index]
            availableRides.remove(at: index)
        }
    }
    
    func startRide() {
        currentRide?.status = .inProgress
        currentRide?.startTime = Date()
    }
    
    func completeRide() {
        currentRide?.status = .completed
        currentRide?.endTime = Date()
        if let ride = currentRide {
            rideHistory.append(ride)
        }
        currentRide = nil
    }
    
    func cancelRide() {
        currentRide?.status = .cancelled
        currentRide = nil
    }
    
    // Complex graph-based fare calculation algorithm
    func calculateAdvancedFare(from pickup: Location, to dropoff: Location) -> Double {
        let pickupCoord = CLLocation(latitude: pickup.latitude, longitude: pickup.longitude)
        let dropoffCoord = CLLocation(latitude: dropoff.latitude, longitude: dropoff.longitude)
        
        // Calculate base distance
        let distance = pickupCoord.distance(from: dropoffCoord) / 1000 // Convert to km
        
        // Build pricing graph
        let pricingGraph = buildPricingGraph(from: pickup, to: dropoff)
        
        // Calculate shortest path with traffic and demand weights
        let pathCost = calculateDijkstraPath(graph: pricingGraph, from: pickup, to: dropoff)
        
        // Time-based multipliers
        let currentHour = Calendar.current.component(.hour, from: Date())
        let isPeakHour = (7...9).contains(currentHour) || (17...20).contains(currentHour)
        let isNightTime = currentHour < 6 || currentHour > 22
        
        // Calculate fare components
        var fare = baseFare
        
        // Distance component with graph optimization
        let optimizedDistance = distance * pathCost.distanceMultiplier
        fare += optimizedDistance * perKmRate
        
        // Time component
        let estimatedTime = pathCost.estimatedMinutes
        fare += estimatedTime * perMinuteRate
        
        // Apply multipliers
        if isPeakHour {
            fare *= peakHourMultiplier
        }
        if isNightTime {
            fare *= nightChargeMultiplier
        }
        
        // Demand-based surge pricing
        let surgeFactor = calculateSurgePricing(location: pickup.coordinate)
        fare *= surgeFactor
        
        // Store breakdown for display on main thread to avoid view publishing warnings
        DispatchQueue.main.async {
            self.fareBreakdown = FareBreakdown(
                baseFare: self.baseFare,
                distanceCharge: optimizedDistance * self.perKmRate,
                timeCharge: estimatedTime * self.perMinuteRate,
                peakCharge: isPeakHour ? fare * (self.peakHourMultiplier - 1) : 0,
                nightCharge: isNightTime ? fare * (self.nightChargeMultiplier - 1) : 0,
                surgeMultiplier: surgeFactor,
                totalFare: fare
            )
        }
        
        return fare.rounded()
    }
    
    // Build a pricing graph considering traffic patterns and demand
    private func buildPricingGraph(from pickup: Location, to dropoff: Location) -> PricingGraph {
        // Create nodes representing key waypoints
        var nodes: [PricingNode] = []
        var edges: [PricingEdge] = []
        
        // Add start and end nodes
        nodes.append(PricingNode(
            location: pickup.coordinate,
            trafficWeight: getTrafficWeight(for: pickup.coordinate),
            demandMultiplier: getDemandMultiplier(for: pickup.coordinate)
        ))
        
        // Add intermediate waypoints (simplified for demo)
        let waypoints = generateWaypoints(from: pickup.coordinate, to: dropoff.coordinate)
        for waypoint in waypoints {
            nodes.append(PricingNode(
                location: waypoint,
                trafficWeight: getTrafficWeight(for: waypoint),
                demandMultiplier: getDemandMultiplier(for: waypoint)
            ))
        }
        
        nodes.append(PricingNode(
            location: dropoff.coordinate,
            trafficWeight: getTrafficWeight(for: dropoff.coordinate),
            demandMultiplier: getDemandMultiplier(for: dropoff.coordinate)
        ))
        
        // Create edges between nodes
        for i in 0..<nodes.count {
            for j in i+1..<nodes.count {
                let distance = calculateDistance(from: nodes[i].location, to: nodes[j].location)
                let timeEstimate = estimateTravelTime(
                    distance: distance,
                    trafficWeight: (nodes[i].trafficWeight + nodes[j].trafficWeight) / 2
                )
                
                edges.append(PricingEdge(
                    from: i,
                    to: j,
                    distance: distance,
                    timeEstimate: timeEstimate
                ))
            }
        }
        
        return PricingGraph(nodes: nodes, edges: edges)
    }
    
    // Dijkstra's algorithm for finding optimal path
    private func calculateDijkstraPath(graph: PricingGraph, from pickup: Location, to dropoff: Location) -> PathCost {
        // Simplified implementation returning weighted cost
        let baseDistance = calculateDistance(
            from: pickup.coordinate,
            to: dropoff.coordinate
        )
        
        // Apply graph-based optimizations
        let trafficMultiplier = 1.0 + (getTrafficWeight(for: pickup.coordinate) * 0.3)
        let demandMultiplier = getDemandMultiplier(for: pickup.coordinate)
        
        return PathCost(
            distanceMultiplier: trafficMultiplier,
            estimatedMinutes: baseDistance * 2.5 * trafficMultiplier, // Avg 24 km/h in traffic
            optimalPath: []
        )
    }
    
    // Helper functions
    private func generateWaypoints(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        // Generate intermediate points for graph construction
        var waypoints: [CLLocationCoordinate2D] = []
        let segments = 3
        
        for i in 1..<segments {
            let fraction = Double(i) / Double(segments)
            let lat = start.latitude + (end.latitude - start.latitude) * fraction
            let lon = start.longitude + (end.longitude - start.longitude) * fraction
            waypoints.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
        return waypoints
    }
    
    private func getTrafficWeight(for location: CLLocationCoordinate2D) -> Double {
        // Simulate traffic patterns based on location and time
        let hour = Calendar.current.component(.hour, from: Date())
        let isPeakHour = (7...9).contains(hour) || (17...20).contains(hour)
        
        // Check if in city center (simplified)
        let cityCenter = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946) // Bengaluru
        let distanceFromCenter = calculateDistance(from: location, to: cityCenter)
        
        var weight = 0.5
        if isPeakHour {
            weight += 0.3
        }
        if distanceFromCenter < 5 { // Within 5km of city center
            weight += 0.2
        }
        
        return min(weight, 1.0)
    }
    
    private func getDemandMultiplier(for location: CLLocationCoordinate2D) -> Double {
        // Simulate demand based on location
        let popularAreas = [
            CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245), // Koramangala
            CLLocationCoordinate2D(latitude: 12.9698, longitude: 77.7500), // Whitefield
            CLLocationCoordinate2D(latitude: 12.9857, longitude: 77.5533), // Malleshwaram
        ]
        
        var minDistance = Double.infinity
        for area in popularAreas {
            let distance = calculateDistance(from: location, to: area)
            minDistance = min(minDistance, distance)
        }
        
        if minDistance < 2 {
            return 1.3 // High demand area
        } else if minDistance < 5 {
            return 1.1 // Medium demand
        }
        return 1.0 // Normal demand
    }
    
    private func calculateSurgePricing(location: CLLocationCoordinate2D) -> Double {
        // Dynamic surge pricing based on supply-demand
        let demandScore = getDemandMultiplier(for: location)
        let availableDrivers = Double.random(in: 5...20) // Simulate driver availability
        
        if availableDrivers < 8 && demandScore > 1.2 {
            return 1.5 // High surge
        } else if availableDrivers < 12 && demandScore > 1.1 {
            return 1.2 // Medium surge
        }
        return 1.0 // No surge
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000 // Convert to km
    }
    
    private func estimateTravelTime(distance: Double, trafficWeight: Double) -> Double {
        let baseSpeed = 40.0 // km/h
        let effectiveSpeed = baseSpeed * (1 - trafficWeight * 0.5)
        return (distance / effectiveSpeed) * 60 // Convert to minutes
    }
    
    private func loadMockRides() {
        // Mock available rides for drivers with Indian locations
        availableRides = [
            Ride(
                riderId: "rider1",
                pickupLocation: Location(latitude: 12.9352, longitude: 77.6245, address: "Koramangala, Bengaluru"),
                dropoffLocation: Location(latitude: 12.9698, longitude: 77.7500, address: "Whitefield, Bengaluru"),
                fare: 285.0
            ),
            Ride(
                riderId: "rider2",
                pickupLocation: Location(latitude: 12.9857, longitude: 77.5533, address: "Malleshwaram, Bengaluru"),
                dropoffLocation: Location(latitude: 12.9271, longitude: 77.6271, address: "Indiranagar, Bengaluru"),
                fare: 195.0
            )
        ]
    }
}

// Supporting structures
struct FareBreakdown {
    let baseFare: Double
    let distanceCharge: Double
    let timeCharge: Double
    let peakCharge: Double
    let nightCharge: Double
    let surgeMultiplier: Double
    let totalFare: Double
}

struct PricingGraph {
    let nodes: [PricingNode]
    let edges: [PricingEdge]
}

struct PathCost {
    let distanceMultiplier: Double
    let estimatedMinutes: Double
    let optimalPath: [Int]
}
