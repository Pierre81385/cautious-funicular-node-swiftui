import SwiftUI
import CoreLocation

struct HomeView: View {
    var currentUser: UserData?
    @State var userManager: UserVM = UserVM()
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    @State var locationManager: LocationManager = LocationManager()
    @State var userOnline: Bool = false
    @State var foundUser: Bool = false
    @State var foundAllUsers: Bool = false
//    @State var logout: Bool = false
    @State var collapseProfile: Bool = true
    @State var collapseUsers: Bool = false
    @State var startChat: Bool = false
    @State var updatingUsers: Bool = false
    @State var showGroupMessage: Bool = false
    @State var selectedGroup: Bool = false
    @State var userAvatar: UIImage?
    @State var showGallery: Bool = false
    @State var locationOff: Bool = false

    var body: some View {
       
            NavigationStack {
                ZStack{
                    //Color(.black)
                VStack {
                    HomeProfileView(imagePickerManager: $imagePickerManager, userManager: $userManager, locationManager: $locationManager, collapseProfile: $collapseProfile, showGallery: $showGallery).padding()
                    if(updatingUsers) {
                        ProgressView().padding()
                    }
                    GroupBox(content: {
                        //Users
                        HomeUsersListView(collapseUsers: $collapseUsers, userManager: $userManager, updatingUsers: $updatingUsers)
                    }).clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                        .shadow(color: .gray.opacity(0.6), radius: 15, x: 5, y: 5)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
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
                }.ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    HomeView()
}
