import SwiftUI

struct ProfileView: View {
    var currentUser: UserData?
    @State var userManager: UserVM = UserVM()
    @State var userOnline: Bool = false
    @State var foundUser: Bool = false
    @State var foundAllUsers: Bool = false
    @State var logout: Bool = false
    @State var collapseProfile: Bool = false
    @State var collapseUsers: Bool = false
    @State var startChat: Bool = false
    @State var updatingUsers: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        userManager.user.online = false
                        Task {
                            await userManager.updateUser(userUpdate: userManager.user)
                        }
                        SocketService.shared.socket.emit("userOffline")
                        logout = true
                    }, label: {
                        Text("LOGOUT").foregroundStyle(.black).padding()
                    })
                    .navigationDestination(isPresented: $logout) {
                        UserView().navigationBarBackButtonHidden(true)
                    }
                    Spacer()
                    if(updatingUsers) {
                        ProgressView().padding()
                    }
                }
                
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("My Profile")
                        .fontWeight(.ultraLight)
                        .font(.system(size: 26))
                    
                    Button(action: {
                        collapseProfile.toggle()
                    }, label: {
                        Image(systemName: collapseProfile ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .tint(.black)
                    })
                    VStack {
                        Divider()
                    }
                }
                
                if !collapseProfile {
                    Text("Username: \(userManager.user.username)")
                    Text("UID: \(userManager.user._id ?? "")")
                    Text("Email: \(userManager.user.email)")
                    
                    if userManager.user.online {
                        VStack {
                            Image(systemName: "wifi").padding()
                                .onTapGesture {
                                    userManager.user.online = false
                                    Task {
                                        await userManager.updateUser(userUpdate: userManager.user)
                                    }
                                    SocketService.shared.socket.emit("userOffline")
                                }
                            Text("ONLINE").fontWeight(.ultraLight).foregroundStyle(.green)
                        }
                        .padding()
                    } else {
                        VStack {
                            Image(systemName: "wifi.slash").padding()
                                .onTapGesture {
                                    userManager.user.online = true
                                    Task {
                                        await userManager.updateUser(userUpdate: userManager.user)
                                    }
                                    SocketService.shared.socket.emit("userOnline")
                                }
                            Text("OFFLINE").fontWeight(.ultraLight).foregroundStyle(.red)
                        }
                        .padding()
                    }
                }
                
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("Users")
                        .fontWeight(.ultraLight)
                        .font(.system(size: 26))
                    
                    Button(action: {
                        collapseUsers.toggle()
                    }, label: {
                        Image(systemName: collapseUsers ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .tint(.black)
                    })
                    VStack {
                        Divider()
                    }
                }
                
                if !collapseUsers {
                    ScrollView {
                        ForEach(userManager.users, id: \._id) { user in
                            if user._id != (userManager.user._id ?? "") {
                                HStack {
                                    if user.online {
                                        Image(systemName: "wifi").foregroundColor(.green)
                                    } else {
                                        Image(systemName: "wifi.slash").foregroundColor(.gray)
                                    }
                                    Text(user.username)
                                    Spacer()
                                    if(user.online) {
                                        Button(action: {
                                            startChat = true
                                        }, label: {
                                            Image(systemName: "chevron.forward").foregroundColor(.black)
                                        })
                                        .navigationDestination(isPresented: $startChat) {
                                            ChatView(sender: $userManager.user, to: user).navigationBarBackButtonHidden(true)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .onChange(of: SocketService.shared.userListUpdateRequired) { updateRequired in
                        updatingUsers = SocketService.shared.userListUpdateRequired
                        if updateRequired {
                            Task {
                                let updated = await userManager.fetchAllUsers()
                                if updated {
                                    SocketService.shared.userListUpdateRequired = false
                                    updatingUsers = SocketService.shared.userListUpdateRequired
                                }
                            }
                        }
                    }
                  
                }
                
                Spacer()
            }
            .onAppear {
                SocketService.shared.socket.connect()
                Task {
                    foundUser = await userManager.fetchUser(byId: currentUser?._id ?? "NoUser")
                    if !userManager.user.online {
                        userManager.user.online = true
                        userOnline = await userManager.updateUser(userUpdate: userManager.user)
                        SocketService.shared.socket.emit("userOnline")
                    }
                    foundAllUsers = await userManager.fetchAllUsers()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
