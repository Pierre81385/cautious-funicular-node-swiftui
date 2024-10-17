//
//  HomeProfileView.swift
//  cautious-funicular
//
//  Created by m1_air on 10/13/24.
//

import SwiftUI

struct HomeProfileView: View {
    @Binding var imagePickerManager: ImagePickerVM
    @Binding var userManager: UserVM
    @Binding var locationManager: LocationManager
    @Binding var collapseProfile: Bool
    @Binding var showGallery: Bool
    @State var logout: Bool = false
    
    var body: some View {
        if(!collapseProfile) {
            HStack{
                Spacer()
                Button(action: {
                    collapseProfile.toggle()
                }, label: {
                    if let avatar = imagePickerManager.images.first {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill() // Fill the frame while maintaining aspect ratio
                            .frame(width: 200, height: 200) // Set a fixed size for the circle
                            .clipShape(Circle()) // Make the image circular
                            .clipped() // Clip any overflowing parts
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .foregroundStyle(.black)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                })
                Spacer()
            }
        }
        HStack {
            Spacer()
            VStack{
                if(collapseProfile) {
                    HStack{
                        Button(action: {
                            collapseProfile.toggle()
                        }, label: {
                            if let avatar = imagePickerManager.images.first {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .scaledToFill() // Fill the frame while maintaining aspect ratio
                                    .frame(width: 50, height: 50) // Set a fixed size for the circle
                                    .clipShape(Circle()) // Make the image circular
                                    .clipped() // Clip any overflowing parts
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .foregroundStyle(.black)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                        })
                        Text(userManager.user.username).padding()
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        
     
            if !collapseProfile {
                VStack{
                Text("Username: \(userManager.user.username)")
                Text("UID: \(userManager.user._id ?? "")")
                Text("Email: \(userManager.user.email)")
                if let myLocation = locationManager.currentLocation {
                    HStack{
                        Text("longitude: \(myLocation.coordinate.longitude)")
                        Text("latitude: \(myLocation.coordinate.latitude)")
                    }.onAppear{
                        locationManager.convertLocationToAddress(location: myLocation)
                    }
                    Text(locationManager.currentAddress).multilineTextAlignment(.center)
                        .onChange(of: locationManager.currentAddress) {
                            userManager.user.longitude = (locationManager.currentLocation?.coordinate.longitude)!
                            userManager.user.latitude = (locationManager.currentLocation?.coordinate.latitude)!
                            Task {
                                await userManager.updateUser(userUpdate: userManager.user)
                            }
                        }
                }
                    HStack{
                        Button(action: {
                            userManager.user.online = false
                            Task {
                                await userManager.updateUser(userUpdate: userManager.user)
                            }
                            SocketService.shared.socket.emit("userOffline")
                            logout = true
                        }, label: {
                            Image(systemName: "chevron.left").foregroundStyle(.black)
                        })
                        .navigationDestination(isPresented: $logout) {
                            EntryView().navigationBarBackButtonHidden(true)
                        }
                        if userManager.user.online {
                            VStack {
                                Image(systemName: "wifi").foregroundStyle(.black).padding()
                                    .onTapGesture {
                                        userManager.user.online = false
                                        Task {
                                            await userManager.updateUser(userUpdate: userManager.user)
                                        }
                                        SocketService.shared.socket.emit("userOffline")
                                    }
                            }
                        } else {
                            VStack {
                                Image(systemName: "wifi.slash").foregroundStyle(.gray).padding()
                                    .onTapGesture {
                                        userManager.user.online = true
                                        Task {
                                            await userManager.updateUser(userUpdate: userManager.user)
                                        }
                                        SocketService.shared.socket.emit("userOnline")
                                    }
                            }
                        }
                        VStack {
                            if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                                Image(systemName: "location.fill").foregroundStyle(.black)
                            } else {
                                Image(systemName: "location.fill").foregroundStyle(.gray)
                            }
                        }
                        if !userManager.user.uploads.isEmpty {
                            Button(action: {
                                showGallery = true
                            }, label: {
                                Image(systemName: "photo.on.rectangle.angled").foregroundStyle(.black).padding()
                            }).sheet(isPresented: $showGallery, content: {
                                ImageGalleryView(images: userManager.user.uploads)
                            })
                        } else {
                            Image(systemName: "photo.on.rectangle.angled").foregroundStyle(.gray).padding()
                        }
                    }
                }
            }
    }
}

//#Preview {
//    HomeProfileView()
//}
