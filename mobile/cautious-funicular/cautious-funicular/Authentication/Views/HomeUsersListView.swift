//
//  HomeUsersListView.swift
//  cautious-funicular
//
//  Created by m1_air on 10/13/24.
//

import SwiftUI

struct HomeUsersListView: View {
    @Binding var collapseUsers: Bool
    @Binding var userManager: UserVM
    @Binding var updatingUsers: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "person.2.fill").foregroundStyle(.black).padding()
            Text("Users")
            Spacer()
            Button(action: {
                collapseUsers.toggle()
            }, label: {
                Image(systemName: collapseUsers ? "chevron.down" : "chevron.up")
                    .tint(.black)
            }).padding()
        }
        
        if !collapseUsers {

            ScrollView {
                ForEach(userManager.users, id: \._id) { user in
                    if user._id != (userManager.user._id ?? "") {
                        GroupBox(content: {
                            UserListItem(currentUser: $userManager.user, thisUser: user)
                        }).clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 5, y: 5)
                            .padding(EdgeInsets(top: 2.5, leading: 2.5, bottom: 2.5, trailing: 15))
                    }
                }
            }.ignoresSafeArea()
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
    }
}

//#Preview {
//    HomeUsersListView()
//}
