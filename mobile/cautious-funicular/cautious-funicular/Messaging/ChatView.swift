//
//  ChatView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//

import SwiftUI
import CryptoKit

struct ChatView: View {
    @Binding var sender: UserData
    var to: UserData
    @State var chatManager: ChatVM = ChatVM()
//    @State var messageManager: MessageViewModel = MessageViewModel()
    @State var chatLoaded: Bool = false
    @State var chatUpdated: Bool = false
    
    let max12DigitNumber: UInt64 = 1_000_000_000_000
    
    func combineIdentifiers(_ id1: UInt64, _ id2: UInt64) -> UInt64 {
        // Safely combine two identifiers using bitwise XOR and limit the result to 12 digits
        return (id1 ^ id2) % max12DigitNumber
    }
    
    var body: some View {
        VStack{
            if(!chatLoaded) {
                ProgressView()
            } else {
                MessageView(sender: $sender, chatManager: $chatManager).onChange(of: SocketService.shared.updateChatMessages, {
                    if(SocketService.shared.updateChatMessages == chatManager.chat.identifier) {
                        Task{
                            await chatManager.fetchChat(byId: chatManager.chat.identifier)
                        }
                        SocketService.shared.updateChatMessages = 0
                        print("messages up to date.")
                    }
                })
            }
        }.onAppear{
            chatManager.chat.participants.append(sender._id ?? "")
            chatManager.chat.participants.append(to._id ?? "")
            chatManager.chat.identifier = Double(Int(combineIdentifiers(UInt64(sender.identifier), UInt64(to.identifier))))
            Task{
                if(await chatManager.fetchChat(byId: chatManager.chat.identifier)) {
                    chatLoaded = true
                } else {
                    chatLoaded = await chatManager.createNewChat()
                }
            }
        }
    }
}


