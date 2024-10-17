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
    @State var showMap: Bool = false
    
    var body: some View {
            VStack{
                HStack{
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
                    Text(thisUser.username)
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
                    Spacer()
                    HStack{
                        Spacer()
                        if thisUser.online {
                                Image(systemName: "wifi").foregroundColor(.green)
                        } else {
                                Image(systemName: "wifi.slash").foregroundColor(.gray)
                        }
                        if !thisUser.uploads.isEmpty {
                            Button(action: {
                                showGallery = true
                            }, label: {
                                Image(systemName: "photo.on.rectangle.angled").foregroundStyle(.orange).padding()
                            }).sheet(isPresented: $showGallery, content: {
                                ImageGalleryView(images: thisUser.uploads)
                            })
                        } else {
                            Image(systemName: "photo.on.rectangle.angled").foregroundStyle(.gray).padding()
                        }
                        if thisUser.longitude != 0.0 {
                            Button(action: {
                                showMap = true
                            }, label: {
                                Image(systemName: "location.fill").foregroundStyle(.blue)
                            }).sheet(isPresented: $showMap, content: {
                                UserMapView(sender: currentUser, recipient: thisUser)
                            })
                        } else {
                            Image(systemName: "location.slash").foregroundColor(.gray)
                        }
                    }
                }
                
        }
        .onAppear{
            Task{
                await imagePickerManager.downloadMedia(byId: thisUser.avatar)
            }
        }
    }
}


