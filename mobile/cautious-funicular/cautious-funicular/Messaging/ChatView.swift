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
    
    var body: some View {
        VStack{
            if(!chatLoaded) {
                ProgressView()
            } else {
                MessageView(sender: $sender, chatManager: $chatManager)
            }
        }.onAppear{
            var chatid = 0
            chatManager.chat.participants.append(sender._id ?? "")
            chatManager.chat.participants.append(to._id ?? "")
            chatid = combinedHashValue(username1: sender.username, username2: to.username)
            chatManager.chat.identifier = chatid
//            messageManager.message.chat = chatid
            Task{
                if(await chatManager.fetchChat(byId: chatid)) {
                    chatLoaded = true
                } else {
                    chatLoaded = await chatManager.createNewChat()

                }
            }
        }
    }
}

func hashToInt(_ input: String) -> Int {
    // Hash the string using SHA256
    let hash = SHA256.hash(data: Data(input.utf8))
    
    // Convert the hash to an integer by treating it as a hexadecimal number
    let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
    
    // Convert the hexadecimal string to an integer
    return Int(hexString.prefix(15), radix: 16) ?? 0 // Limiting to 15 digits for safety
}

func combinedHashValue(username1: String, username2: String) -> Int {
    // Hash each username and convert it to an integer
    let hash1 = hashToInt(username1)
    let hash2 = hashToInt(username2)
    
    // Combined hashes create the unique room identifier so no matter which user initiates, the Chat ID is the same and unique
    return hash1 + hash2
}

