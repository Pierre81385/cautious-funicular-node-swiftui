//
//  UserView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/6/24.
//

import SwiftUI

struct EntryView: View {
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
                    Spacer()
                    Image(systemName: "point.3.filled.connected.trianglepath.dotted").resizable()
                        .frame(width: 160, height: 150)
                    Spacer()
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
                            }).foregroundStyle(.gray)
                        }
                    }
                        TextField("Username", text: $userManager.user.username)
                        .tint(.black)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        
                        SecureField("Password", text: $userManager.user.password)
                        .tint(.black)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        if(new) {
                            SecureField("Verify Password", text: $verifyPassword).padding()
                        }
                        Button("Submit", action: {
                            Task{
                                success = await userManager.authenticateUser()
                            }
                        }).navigationDestination(isPresented: $success, destination: {
                            HomeView(currentUser: userManager.user).navigationBarBackButtonHidden(true)
                            })
                        .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.black)
                                                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                                                )
                }
                .onAppear{
                    SocketService.shared.socket.disconnect()
                }
            } else {
                EntryRegistrationView(showLogin: $showLogin)
            }
        }
    }
}



#Preview {
    EntryView()
}

