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
    @State var userManager: UserVM = UserVM()
    @State var chatLoaded: Bool = false
    @State var chatUpdated: Bool = false
    @State var chatParticipants: [UserData] = []
    @State var back: Bool = false
    @State var hideUsers: Bool = true
    
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
                ZStack{
                    MessageView(sender: $sender, chatManager: $chatManager).onChange(of: SocketService.shared.updateChatMessages, {
                        if(SocketService.shared.updateChatMessages == chatManager.chat.identifier) {
                            Task{
                                
                                await chatManager.fetchChat(byId: chatManager.chat.identifier)
                                
                            }
                            SocketService.shared.updateChatMessages = 0
                            print("messages up to date.")
                        }
                    })
                    VStack{
                        HStack{
                            VStack{
                                Button(action: {
                                    back = true
                                }, label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)  // White text (icon color)
                                        .padding()  // Add padding to make the button larger
                                        .background(Circle().fill(Color.black))  // Circular black background
                                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)  // Drop shadow
                                }).padding()
                                    .navigationDestination(isPresented: $back, destination: {
                                        ProfileView(currentUser: sender).navigationBarBackButtonHidden(true)
                                    })
                                Spacer()
                            }
                            Spacer()
                            VStack{
                                
                                if (!hideUsers) {
                                    ForEach(chatParticipants, id: \._id) {
                                        user in
                                        Text("\(user.username) ")
                                            .foregroundColor(.white)  // White text (icon color)
                                            .padding()  // Add padding to make the button larger
                                            .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(Color.black))  // Circular black background
                                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)  // Drop shadow
                                    }
                                }
                                Button(action: {
                                    hideUsers.toggle()
                                }, label: {
                                    if(hideUsers) {
                                        Image(systemName: "person")
                                            .foregroundColor(.white)  // White text (icon color)
                                            .padding()
                                            .background(Circle().fill(Color.black))  // Circular black background
                                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)  // Drop shadow
                                    } else {// Drop shadow
                                        Image(systemName: "chevron.up")
                                            .foregroundColor(.white)  // White text (icon color)
                                            .padding()  // Add padding to make the button larger
                                            .background(Circle().fill(Color.black))  // Circular black background
                                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)  // Drop shadow
                                    }
                                })
                                Spacer()
                                
                            }.padding()
                        }.padding()
                        Spacer()
                    }.padding()
                }.ignoresSafeArea(edges: .top)
            }
        }.onAppear{
            if(!chatManager.chat.participants.contains(sender._id!)) {
                chatManager.chat.participants.append(sender._id ?? "")
            }
            if(!chatManager.chat.participants.contains(to._id!)) {
                chatManager.chat.participants.append(to._id ?? "")
            }
            chatManager.chat.identifier = Double(Int(combineIdentifiers(UInt64(sender.identifier), UInt64(to.identifier))))
            Task{
                if(await chatManager.fetchChat(byId: chatManager.chat.identifier)) {
                    chatLoaded = true
                } else {
                    chatLoaded = await chatManager.createNewChat()
                }
                for id in chatManager.chat.participants {
                    try await userManager.fetchUser(byId: id)
                    let user = userManager.user
                    if !chatParticipants.contains(where: { $0 == user }) {
                        chatParticipants.append(user)
                    }
                }

            }
            
        }
    }
}


