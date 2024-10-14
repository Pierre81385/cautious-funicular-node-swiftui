//
//  UserListItem.swift
//  cautious-funicular
//
//  Created by m1_air on 10/8/24.
//

import SwiftUI

struct UserListItem: View {
    @Binding var currentUser: UserData
    var thisUser: UserData
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    @State var startChat: Bool = false
    @State var showGallery: Bool = false
    
    var body: some View {
        HStack {
            if let avatar = imagePickerManager.images.first {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill() // Fill the frame while maintaining aspect ratio
                    .frame(width: 50, height: 50) // Set a fixed size for the circle
                    .clipShape(Circle()) // Make the image circular
                    .clipped() // Clip any overflowing parts
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding() // Add some spacing
            }
            if thisUser.online {
                HStack{
                    Text(thisUser.username)
                    Image(systemName: "wifi").foregroundColor(.green)
                }
            } else {
                HStack{
                    Text(thisUser.username)
                    Image(systemName: "wifi.slash").foregroundColor(.gray)
                }
            }
            if !thisUser.uploads.isEmpty {
                Button(action: {
                    showGallery = true
                }, label: {
                    Image(systemName: "photo.on.rectangle.angled").foregroundStyle(.black).padding()
                }).sheet(isPresented: $showGallery, content: {
                    ImageGalleryView(images: thisUser.uploads)
                })
            }
            if thisUser.longitude != 0 {
                Button(action: {}, label: {
                    Image(systemName: "location.fill").foregroundStyle(.blue).padding()
                })
            } else {
                Image(systemName: "location.slash").foregroundColor(.gray)
            }
            Spacer()
            if(thisUser.online) {
                Button(action: {
                    startChat = true
                }, label: {
                    Image(systemName: "chevron.forward").foregroundColor(.black)
                })
                .navigationDestination(isPresented: $startChat) {
                    ChatView(sender: $currentUser, to: thisUser).navigationBarBackButtonHidden(true)
                }
            }
        }
        .padding()
        .onAppear{
            Task{
                await imagePickerManager.downloadMedia(byId: thisUser.avatar)
            }
        }
    }
}


