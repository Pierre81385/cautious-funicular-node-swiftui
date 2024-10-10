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
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    @State var userManager: UserVM = UserVM()
    
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
                    MediaPickerView(imagePickerVM: $imagePickerManager, maxSelection: 5, iconWidth: 50, iconHeight: 50, icon: imagePickerManager.images.isEmpty ? "paperclip.circle" : "paperclip.circle.fill")
                    TextField("Say something...", text: $messageText)
                    Button(action: {
                        Task {
                                // Ensure that the media upload completes first
                                await imagePickerManager.uploadMedia()
                            
                                // Once the upload completes, create and send the message
                                let newMessage = MessageData(sender: sender._id!, textContent: messageText, mediaContent: imagePickerManager.imageIds)
                                chatManager.chat.messages.append(newMessage)
                                
                                await chatManager.updateChat(byId: chatManager.chat.identifier)
                            
                            sender.uploads.append(contentsOf: imagePickerManager.imageIds)
                            await userManager.updateUser(userUpdate: sender)

                                // Emit the messageSent event after everything is updated
                                SocketService.shared.socket.emit("messageSent", ["identifier": chatManager.chat.identifier])
    
                                // Optionally, clear the text field after sending
                                // messageText = ""
                            imagePickerManager.selectedItems = []
                            imagePickerManager.images = []
                            imagePickerManager.imageIds = []
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
