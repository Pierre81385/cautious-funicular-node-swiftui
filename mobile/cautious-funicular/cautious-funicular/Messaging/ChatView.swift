//
//  ChatView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//

import SwiftUI
import CryptoKit

struct ChatView: View {
    var sender: UserData?
    var to: [UserData]?
    @State var chatManager: ChatVM = ChatVM()
    
    var body: some View {
        VStack{
            
        }.onAppear{
            chatManager.chat.participants.append(sender?._id ?? "")
            chatManager.chat.participants.append(to?[0]._id ?? "")
            chatManager.chat.identifier = combinedHashValue(username1: sender?.username ?? "", username2: to?[0].username ?? "")
            Task{
                await chatManager.createNewChat()
            }
        }
    }
}

#Preview {
    ChatView()
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

