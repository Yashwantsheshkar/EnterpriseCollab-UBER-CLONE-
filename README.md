# 🚗 Enterprise Collaboration Mobile App (Uber Clone)

A sophisticated ride-sharing iOS application built with SwiftUI, featuring dual interfaces for riders and drivers, real-time location tracking, and an advanced graph-based pricing algorithm.

![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 📱 Features

### Core Functionality
- **Dual User Interfaces**: Seamless switching between Rider and Driver modes
- **Real-time Location Services**: Live GPS tracking with MapKit integration
- **Smart Location Search**: Real-time address search with autocomplete
- **Graph-Based Pricing**: Advanced pricing algorithm using Dijkstra's shortest path
- **In-App Messaging**: Real-time chat between riders and drivers
- **Dynamic Fare Calculation**: Considers traffic, demand, time, and distance

### Rider Features
- 📍 Automatic pickup location from current GPS position
- 🔍 Real-time location search for destinations
- 💰 Instant fare estimation with detailed breakdown
- 🗺️ Live ride tracking on map
- 💬 Chat with driver during ride
- 📊 Ride history and receipts

### Driver Features
- 🟢 Online/Offline toggle
- 📋 View available ride requests with fare details
- 🗺️ See pickup locations on map
- ✅ Accept/Decline rides
- 💵 Earnings tracking
- ⭐ Ratings system

## 🛠️ Technology Stack

- **Language**: Swift 5.5+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Location Services**: Core Location & MapKit
- **State Management**: Combine Framework
- **Async Operations**: Swift Concurrency (async/await)
- **Pricing Algorithm**: Graph Theory with Dijkstra's Algorithm

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+
- iPhone/iPad (for testing on device)

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/enterprise-collab-app.git
cd enterprise-collab-app
```

### 2. Create Xcode Project
1. Open Xcode
2. Create a new project:
   - **Platform**: iOS
   - **Template**: App
   - **Product Name**: EnterpriseCollabApp
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Use Core Data**: No
   - **Include Tests**: Optional

### 3. Configure Info.plist
Add the following privacy permissions to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show available rides and navigate.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location to track rides even when in background.</string>
```

**Visual Method**:
1. Click on your project in Xcode
2. Select your app target
3. Go to "Info" tab
4. Add the location usage descriptions

### 6. Build and Run
1. Select a simulator (iPhone 14 or later recommended)
2. Press `Cmd + R` to build and run
3. Allow location permissions when prompted

## 📱 Usage

### First Launch
1. The app will request location permissions - tap "Allow While Using App"
2. You'll see the login screen

### As a Rider
1. Select "Rider" mode and tap Login (any email/password works)
2. Your current location is automatically set as pickup
3. Tap "Where to?" to search for a destination
4. View fare estimate and confirm ride
5. Track your driver in real-time
6. Chat with driver if needed

### As a Driver
1. Select "Driver" mode and tap Login
2. Toggle to "Online" to start receiving rides
3. View available ride requests with fares
4. Tap a ride to see details
5. Accept rides and navigate to pickup
6. Start ride when passenger is picked up
7. Complete ride at destination

## 🧮 Pricing Algorithm

The app uses a sophisticated graph-based pricing system:

### Base Rates (Indian Rupees)
- Base Fare: ₹50
- Per Kilometer: ₹15
- Per Minute: ₹2

### Dynamic Multipliers
- **Peak Hours** (7-9 AM, 5-8 PM): 1.5x
- **Night Charges** (10 PM - 6 AM): 1.2x
- **Surge Pricing**: 1.0x - 1.5x based on demand

### Algorithm Features
- Traffic weight calculation (0-1 scale)
- Demand-based area multipliers
- Dijkstra's shortest path optimization
- Real-time fare adjustments

## 🏗️ Architecture

### MVVM Pattern
```
View (SwiftUI) ←→ ViewModel (ObservableObject) ←→ Model (Data)
     ↓                      ↓                         ↓
   UI Layer          Business Logic            Data Structures
```

### Key ViewModels
- **AuthViewModel**: Handles user authentication and sessions
- **LocationViewModel**: Manages GPS and location search
- **RideViewModel**: Controls ride lifecycle and pricing
- **ChatViewModel**: Handles messaging between users

## 🎨 Customization

### Changing Default Location
In `LocationViewModel.swift`:
```swift
// Change default city coordinates
userLocation = CLLocationCoordinate2D(latitude: YOUR_LAT, longitude: YOUR_LONG)
```

### Adjusting Pricing
In `RideViewModel.swift`:
```swift
private let baseFare: Double = 50.0      // Change base fare
private let perKmRate: Double = 15.0     // Change per km rate
private let perMinuteRate: Double = 2.0  // Change per minute rate
```

### Adding Popular Areas
```swift
let popularAreas = [
    CLLocationCoordinate2D(latitude: LAT1, longitude: LONG1),
    CLLocationCoordinate2D(latitude: LAT2, longitude: LONG2),
    // Add more areas
]
```

## 🐛 Troubleshooting

### Location Not Updating
1. Ensure location permissions are granted
2. On simulator: Debug → Location → City Bicycle Ride
3. On device: Check Settings → Privacy → Location Services

### Build Errors
1. Clean build folder: `Cmd + Shift + K`
2. Delete derived data: `~/Library/Developer/Xcode/DerivedData`
3. Restart Xcode

### Map Not Loading
1. Ensure internet connection
2. Check if MapKit is properly imported
3. Verify coordinate region is valid

## 📈 Future Enhancements

- [ ] Firebase integration for real-time updates
- [ ] Payment gateway integration (Stripe/Razorpay)
- [ ] Push notifications
- [ ] Driver route optimization
- [ ] Multi-language support
- [ ] Ride sharing/pooling option
- [ ] Rating and review system
- [ ] Earnings analytics for drivers

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgments

- SwiftUI for the amazing declarative UI framework
- MapKit for location services
- The iOS development community for inspiration

**Note**: This is a demonstration project showcasing iOS development skills with SwiftUI and advanced algorithms. For production use, implement proper backend services, authentication, and payment processing.
