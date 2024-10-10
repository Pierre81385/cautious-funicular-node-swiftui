import SwiftUI

struct ProfileView: View {
    var currentUser: UserData?
    @State var userManager: UserVM = UserVM()
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    @State var userOnline: Bool = false
    @State var foundUser: Bool = false
    @State var foundAllUsers: Bool = false
    @State var logout: Bool = false
    @State var collapseProfile: Bool = false
    @State var collapseUsers: Bool = false
    @State var startChat: Bool = false
    @State var updatingUsers: Bool = false
    @State var showGroupMessage: Bool = false
    @State var selectedGroup: Bool = false
    @State var userAvatar: UIImage?

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
                if let avatar = imagePickerManager.images.first {
                    Image(uiImage: avatar)
                        .resizable()
                        .scaledToFill() // Fill the frame while maintaining aspect ratio
                        .frame(width: 200, height: 200) // Set a fixed size for the circle
                        .clipShape(Circle()) // Make the image circular
                        .clipped() // Clip any overflowing parts
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding() // Add some spacing
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
                        
                        HStack{
                            if userManager.user.online {
                                VStack {
                                    Image(systemName: "wifi").foregroundStyle(.green).padding()
                                        .onTapGesture {
                                            userManager.user.online = false
                                            Task {
                                                await userManager.updateUser(userUpdate: userManager.user)
                                            }
                                            SocketService.shared.socket.emit("userOffline")
                                        }
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
                                }
                                .padding()
                            }
                            if !userManager.user.uploads.isEmpty {
                                Button(action: {}, label: {
                                    Image(systemName: "photo.on.rectangle.angled").foregroundStyle(.black).padding()
                                })
                            }
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
                                UserListItem(currentUser: $userManager.user, thisUser: user)
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
                    if await imagePickerManager.downloadMedia(byId: userManager.user.avatar) {
                        //???
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
