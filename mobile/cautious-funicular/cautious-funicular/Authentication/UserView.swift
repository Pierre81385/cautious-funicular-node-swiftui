//
//  UserView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/6/24.
//

import SwiftUI

struct UserView: View {
    @State var userManager: UserVM = UserVM()
    @State var verifyPassword: String = ""
    @State var new: Bool = false
    @State var success: Bool = false
    @State var message: [String] = ["Hello, World"]
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                if(new) {
                    
                    HStack{
                        VStack{
                            Divider()
                        }
                        Text("REGISTER").fontWeight(.ultraLight).font(.system(size: 26))
                        VStack{
                            Divider()
                        }
                    }      
                    Toggle("New account", isOn: $new).tint(.black).padding()
                    TextField("Email", text: $userManager.user.email).autocorrectionDisabled(true).textInputAutocapitalization(TextInputAutocapitalization.never).padding()
                } else {
                    VStack{
                        HStack{
                            VStack{
                                Divider()
                            }
                            Text("LOGIN").fontWeight(.ultraLight).font(.system(size: 26))
                            VStack{
                                Divider()
                            }
                        }
                        Toggle("New account", isOn: $new).tint(.black).padding()

                    }
                }
                TextField("Username", text: $userManager.user.username).padding()
                SecureField("Password", text: $userManager.user.password).padding()
                if(new) {
                    SecureField("Verify Password", text: $verifyPassword).padding()
                }
                Button("Submit", action: {
                    if(new) {
                        if(userManager.user.email.isEmpty || userManager.user.username.isEmpty || userManager.user.password.isEmpty) {
                            print("Show Alert")
                        } else {
                            Task{
                               success = await userManager.createNewUser()
                            }
                        }
                    } else {
                        Task{
                            success = await userManager.authenticateUser()
                        }
                    }
                }).tint(.black).padding()
                    .onChange(of: userManager.error, {
                        message.append(userManager.error)
                    })
                    .navigationDestination(isPresented: $success, destination: {
                        ProfileView(currentUser: userManager.user).navigationBarBackButtonHidden(true)
                    })
    
            }.onChange(of: SocketService.shared.message, {
                message.append(SocketService.shared.message)
            })
            .onAppear{
                SocketService.shared.socket.disconnect()
            }
        }
    }
}


#Preview {
    UserView()
}
