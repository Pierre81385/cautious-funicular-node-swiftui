//
//  MessageView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/19/24.
//

import SwiftUI

struct MessageView: View {
    @Binding var sender: UserData
    @Binding var chatManager: ChatVM
    @State var chatUpdating: Bool = false
    @State var messageText: String = ""
    @State var showImagePicker: Bool = false
    @State var imageManager: ImagePickerViewModel = ImagePickerViewModel()
    

    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
                    VStack {
                        ForEach(chatManager.chat.messages.reversed(), id: \._id) { message in
                            if chatUpdating {
                                ProgressView()
                            } else {
                                // Check the sender and display the corresponding view
                                if message.sender == sender._id {
                                    SenderMessage(message: message)
                                        .background(Color(UIColor.systemGroupedBackground)) // Set the background color for the message
                                        .cornerRadius(10)
                                        .padding(.horizontal) // Add horizontal padding
                                        .padding(.vertical, 5) // Add some space between messages
                                } else {
                                    MessageFeed(message: message)
                                        .background(Color(UIColor.systemGroupedBackground)) // Set the background color for the message
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground)) // Set the background color for the entire ScrollView
                .ignoresSafeArea(edges: .top)
                .onChange(of: chatManager.chat.messages) {
                    messageText = ""
                }
                .onChange(of: SocketService.shared.updateChatMessages) { oldValue, newValue in
                    chatUpdating = true
                    if newValue == chatManager.chat.identifier {
                        Task {
                            if await chatManager.fetchChat(byId: newValue) {
                                chatUpdating = false
                            }
                        }
                        SocketService.shared.updateChatMessages = 0
                        print("messages up to date.")
                    }
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                HStack{
                    MediaPickerView(imagePickerVM: $imageManager)
                    TextField("Say something...", text: $messageText)
                    Button(action: {
                        Task {
                                // Ensure that the media upload completes first
                                await imageManager.uploadMedia()

                                // Once the upload completes, create and send the message
                                let newMessage = MessageData(sender: sender._id!, textContent: messageText, mediaContent: imageManager.imageIds)
                                chatManager.chat.messages.append(newMessage)
                                
                                await chatManager.updateChat(byId: chatManager.chat.identifier)

                                // Emit the messageSent event after everything is updated
                                SocketService.shared.socket.emit("messageSent", ["identifier": chatManager.chat.identifier])

                                // Optionally, clear the text field after sending
                                // messageText = ""
                            imageManager.selectedItems = []
                            imageManager.images = []
                            imageManager.imageIds = []
                            }
                    }, label: {
                        if(messageText.count < 1) {
                            Image(systemName: "paperplane.fill").foregroundStyle(.black)
                        } else {
                            Image(systemName: "paperplane.fill").foregroundStyle(.green)
                        }
                    })
                }.padding()
            }
        }
    }
}

struct MessageFeed: View {
    var message: MessageData
    @State var userManager: UserVM = UserVM()
    @State var imageManager: ImagePickerViewModel = ImagePickerViewModel()
    
    // A Set to keep track of messages whose images have already been loaded
    @State private var loadedMessages: Set<String> = []

    var body: some View {
        VStack {
            // Display images if any are available
            if !imageManager.images.isEmpty {
                // Use VStack to stack images vertically
                ForEach(imageManager.images, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill() // Fill the frame while maintaining aspect ratio
                        .frame(width: 300) // Set a fixed height for each image
                        .cornerRadius(20) // Apply corner radius for rounded corners
                        .clipped() // Clip any overflowing parts
                        .rotationEffect(.degrees(180)) // Rotate the image 180 degrees
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 10) // Add some spacing between images
                }
                .padding()
            }

            // Text content of the message
            HStack {
                VStack(alignment: .leading) {
                    Text(userManager.user.username).font(.headline)
                    Text(message.textContent)
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                Spacer()
            }
            .onAppear {
                Task {
                    await userManager.fetchUser(byId: message.sender)
                }
                
                // Check if images for this message have already been loaded
                if !loadedMessages.contains(message._id) {
                    // Load images for new messages
                    if !message.mediaContent.isEmpty {
                        for id in message.mediaContent {
                            Task {
                                await imageManager.downloadMedia(byId: id)
                            }
                        }
                        // Mark this message as loaded
                        loadedMessages.insert(message._id)
                    }
                }
            }
        }
        .padding() // Add padding to the entire VStack
        .background(Color(UIColor.systemGroupedBackground)) // Match List background color
        .cornerRadius(10) // Optional: Add corner radius for the entire message
        //.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Optional: Add a subtle shadow
    }
}

struct SenderMessage: View {
    var message: MessageData
    @State var userManager: UserVM = UserVM()
    @State var imageManager: ImagePickerViewModel = ImagePickerViewModel()
    
    // A Set to keep track of messages whose images have already been loaded
    @State private var loadedMessages: Set<String> = []

    var body: some View {
        VStack {
            // Display images if any are available
            if !imageManager.images.isEmpty {
                // Use VStack to stack images vertically
                ForEach(imageManager.images, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill() // Fill the frame while maintaining aspect ratio
                        .frame(width: 300) // Set a fixed width for each image
                        .cornerRadius(20) // Apply corner radius for rounded corners
                        .clipped() // Clip any overflowing parts
                        .rotationEffect(.degrees(180)) // Rotate the image 180 degrees
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 10) // Add some spacing between images
                }
                .padding()
            }

            // Text content of the message
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(userManager.user.username).font(.headline)
                    Text(message.textContent)
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
            }
            .onAppear {
                // Fetch sender information
                Task {
                    await userManager.fetchUser(byId: message.sender)
                }
                
                // Check if images for this message have already been loaded
                if !loadedMessages.contains(message._id) {
                    // Load images for new messages
                    if !message.mediaContent.isEmpty {
                        for id in message.mediaContent {
                            Task {
                                await imageManager.downloadMedia(byId: id)
                            }
                        }
                        // Mark this message as loaded
                        loadedMessages.insert(message._id)
                    }
                }
            }
        }
        .padding() // Add padding to the entire VStack
        .background(Color(UIColor.systemGroupedBackground)) // Match List background color
        .cornerRadius(10) // Optional: Add corner radius for the entire message
        //.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Optional: Add a subtle shadow
    }
}

//#Preview {
//    MessageView()
//}
