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
    @State var showLogin: Bool = true
    
    var body: some View {
        NavigationStack{
            if(showLogin){
                VStack{
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
                        HStack{
                            Text("Don't have an account?")
                            Button("Register", action: {
                                showLogin = false
                            })
                        }
                    }
                    TextField("Username", text: $userManager.user.username).padding()
                    SecureField("Password", text: $userManager.user.password).padding()
                    if(new) {
                        SecureField("Verify Password", text: $verifyPassword).padding()
                    }
                    Button("Submit", action: {
                        
                        Task{
                            success = await userManager.authenticateUser()
                        }
                        
                    }).tint(.black).padding()
                        .navigationDestination(isPresented: $success, destination: {
                            ProfileView(currentUser: userManager.user).navigationBarBackButtonHidden(true)
                        })
                    
                }
                .onAppear{
                    SocketService.shared.socket.disconnect()
                }
            } else {
                NewUserForm(showLogin: $showLogin)
            }
        }
    }
}


#Preview {
    UserView()
}
