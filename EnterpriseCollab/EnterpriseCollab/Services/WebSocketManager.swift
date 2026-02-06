import Foundation

/// WebSocket manager for real-time messaging
/// Handles connection, reconnection, and message streaming
final class WebSocketManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var lastMessage: Message?
    @Published var connectionError: APError?
    
    // MARK: - Properties
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var currentRideId: String?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var messageHandler: ((Message) -> Void)?
    
    // MARK: - Singleton
    
    static let shared = WebSocketManager()
    
    // MARK: - Initialization
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Connection Methods
    
    /// Connects to the WebSocket server for a specific ride
    /// - Parameters:
    ///   - rideId: ID of the ride to connect to
    ///   - onMessage: Callback for received messages
    func connect(rideId: String, onMessage: @escaping (Message) -> Void) {
        guard !isConnected else { return }
        
        currentRideId = rideId
        messageHandler = onMessage
        
        // Build WebSocket URL
        let wsURL = URL(string: "wss://api.yourbackend.com/ws/chat/\(rideId)")!
        
        // Create WebSocket task
        webSocketTask = session?.webSocketTask(with: wsURL)
        
        // Add auth token as header before connecting
        // Note: URLSessionWebSocketTask doesn't support custom headers directly
        // You may need to pass the token as a query parameter
        
        // Start connection
        webSocketTask?.resume()
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.reconnectAttempts = 0
        }
        
        // Start receiving messages
        receiveMessage()
    }
    
    /// Disconnects from the WebSocket server
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.currentRideId = nil
        }
    }
    
    // MARK: - Send Message
    
    /// Sends a message through the WebSocket
    /// - Parameter message: Message to send
    func send(message: Message) {
        guard isConnected else {
            print("WebSocket not connected. Cannot send message.")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(message)
            
            webSocketTask?.send(.data(data)) { [weak self] error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                    self?.handleConnectionError()
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
    
    // MARK: - Receive Message
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleReceivedText(text)
                case .data(let data):
                    self?.handleReceivedData(data)
                @unknown default:
                    break
                }
                
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.handleConnectionError()
            }
        }
    }
    
    private func handleReceivedText(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        handleReceivedData(data)
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(Message.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                self?.lastMessage = message
                self?.messageHandler?(message)
            }
        } catch {
            print("Failed to decode received message: \(error)")
        }
    }
    
    // MARK: - Error Handling
    
    private func handleConnectionError() {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        
        // Attempt reconnection
        if reconnectAttempts < maxReconnectAttempts {
            reconnectAttempts += 1
            let delay = Double(reconnectAttempts) * 2.0 // Exponential backoff
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self,
                      let rideId = self.currentRideId,
                      let handler = self.messageHandler else { return }
                
                print("Attempting WebSocket reconnection (\(self.reconnectAttempts)/\(self.maxReconnectAttempts))...")
                self.connect(rideId: rideId, onMessage: handler)
            }
        } else {
            DispatchQueue.main.async {
                self.connectionError = APError.networkError(
                    NSError(domain: "WebSocket", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to connect after multiple attempts"
                    ])
                )
            }
        }
    }
    
    // MARK: - Ping/Pong for Keep-Alive
    
    /// Sends a ping to keep the connection alive
    func ping() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                print("WebSocket ping failed: \(error)")
                self?.handleConnectionError()
            }
        }
    }
}
