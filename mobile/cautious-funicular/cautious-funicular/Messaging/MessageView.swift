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
    @State var messageText: String = ""
    @State var showImagePicker: Bool = false
    @State var imageManager: ImagePickerViewModel = ImagePickerViewModel()
    

    var body: some View {
        NavigationStack{
            VStack{
                List(chatManager.chat.messages.reversed(), id: \._id) {
                    message in
                    if(message.sender == sender._id) {
                        SenderMessage(message: message)
                    } else {
                        MessageFeed(message: message)
                    }
                }.ignoresSafeArea(edges: .top)
                .onChange(of: chatManager.chat.messages, {
                    messageText = ""
                })
                .rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                HStack{
                    Button(action: {
                        showImagePicker = true
                    }, label: {
                        if(imageManager.isUploading) {
                            ProgressView()
                        } else {
                            if(imageManager.imageIds.isEmpty) {
                                Image(systemName: "photo.on.rectangle.fill").tint(.black)
                            } else {
                                Image(systemName: "photo.badge.checkmark.fill").tint(.black)
                            }
                        }
                    }).sheet(isPresented: $showImagePicker, content: {
                        MediaPickerView(imagePickerVM: $imageManager, showImagePicker: $showImagePicker)
                    })
                    TextField("Say something...", text: $messageText)
                    Button(action: {
                        let newMessage = MessageData(sender: sender._id!, textContent: messageText, mediaContent: imageManager.imageIds)
                        chatManager.chat.messages.append(newMessage)
                        Task{
                            await chatManager.updateChat(byId: chatManager.chat.identifier)
                        }
//                        messageText = ""
                        SocketService.shared.socket.emit("messageSent", ["identifier": chatManager.chat.identifier])
                    }, label: {
                        Image(systemName: "paperplane.fill").foregroundStyle(.green)
                    })
                }.padding()
            }
        }
    }
}

struct MessageFeed: View {
    var message: MessageData
    @State var userManager: UserVM = UserVM()

    var body: some View {
            HStack {
                VStack.init(alignment: .leading) {
                    Text(userManager.user.username).font(.headline)
                    Text(message.textContent)
                }.rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                Spacer()
            }.onAppear{
                Task{
                    await userManager.fetchUser(byId: message.sender)
                }
            }
        }
}

struct SenderMessage: View {
    var message: MessageData
    @State var userManager: UserVM = UserVM()

    var body: some View {
        HStack {
            Spacer()
            VStack.init(alignment: .trailing) {
                Text(userManager.user.username).font(.headline)
                Text(message.textContent)
            }
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
        }.onAppear{
            //get sender information
            Task{
                await userManager.fetchUser(byId: message.sender)
            }
        }
    }
}


//#Preview {
//    MessageView()
//}
