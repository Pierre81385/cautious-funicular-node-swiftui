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
    

    var body: some View {
        VStack{
            List(chatManager.chat.messages.reversed(), id: \._id) {
                message in
                if(message.sender == sender._id) {
                    SenderMessage(message: message)
                } else {
                    MessageFeed(message: message)
                }
            }.rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                .onAppear{
                }
            HStack{
                TextField("Say something...", text: $messageText)
                Button(action: {
                    let newMessage = MessageData(sender: sender._id!, textContent: messageText, mediaContent: [])
                    chatManager.chat.messages.append(newMessage)
                    Task{
                        await chatManager.updateChat(byId: chatManager.chat.identifier)
                    }
                    messageText = ""
                }, label: {
                    Image(systemName: "paperplane.fill")
                })
            }
        }
    }
}

struct MessageFeed: View {
    var message: MessageData

    var body: some View {
            HStack {
                VStack.init(alignment: .leading) {
                    Text(message.textContent)
                    Text(message.sender).font(.headline)
                }.rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                Spacer()
            }.onAppear{
                //get sender information
            }
        }
}

struct SenderMessage: View {
    var message: MessageData

    var body: some View {
        HStack {
            Spacer()
            VStack.init(alignment: .trailing) {
                Text(message.textContent)
                Text(message.sender).font(.headline)
            }
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
        }.onAppear{
            //get sender information
        }
    }
}


//#Preview {
//    MessageView()
//}
