import SwiftUI

struct ChatView: View {
    let currentUserId: String
    let otherUserId: String
    let otherUserName: String
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var messageText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages List
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(chatViewModel.currentChat) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == currentUserId
                            )
                        }
                    }
                    .padding()
                }
                
                // Input Field
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .navigationTitle(otherUserName)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                chatViewModel.loadChat(between: currentUserId, and: otherUserId)
            }
        }
    }
    
    func sendMessage() {
        chatViewModel.sendMessage(
            from: currentUserId,
            to: otherUserId,
            content: messageText
        )
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            Text(message.content)
                .padding()
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(20)
                .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser { Spacer() }
        }
    }
}
