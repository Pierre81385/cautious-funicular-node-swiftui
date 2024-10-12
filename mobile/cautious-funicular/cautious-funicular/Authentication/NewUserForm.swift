//
//  NewUserForm.swift
//  cautious-funicular
//
//  Created by m1_air on 10/8/24.
//

import SwiftUI

struct NewUserForm: View {
    @State var userManager: UserVM = UserVM()
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    @State var verifyPassword: String = ""
    @State var success: Bool = false
    @Binding var showLogin: Bool
    
    var body: some View {
        VStack{
            if let preview = imagePickerManager.images.first {
                VStack{
                    Spacer()
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFill() // Fill the frame while maintaining aspect ratio
                        .frame(width: 200, height: 200) // Set a fixed size for the circle
                        .clipShape(Circle()) // Make the image circular
                        .clipped() // Clip any overflowing parts
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .onTapGesture {
                            imagePickerManager.images = []
                            imagePickerManager.imageIds = []
                        }
                    Spacer()
                }
            } else {
                VStack{
                    Spacer()
                    MediaPickerView(imagePickerVM: $imagePickerManager, maxSelection: 1, iconWidth: 50, iconHeight: 50, icon: "camera.circle")
                    Spacer()
                }
            }
            HStack{
                VStack{
                    Divider()
                }
                Text("REGISTER").fontWeight(.ultraLight).font(.system(size: 26))
                VStack{
                    Divider()
                }
            }
            HStack{
                Text("Already have an account?")
                Button("Login", action: {
                    showLogin = true
                }).tint(.gray)
            }
            TextField("Email", text: $userManager.user.email).autocorrectionDisabled(true).textInputAutocapitalization(TextInputAutocapitalization.never).padding()
            TextField("Username", text: $userManager.user.username).padding()
            SecureField("Password", text: $userManager.user.password).padding()
            SecureField("Verify Password", text: $verifyPassword).padding()
            Button("Submit & Login", action: {
               
                if(userManager.user.email.isEmpty || userManager.user.username.isEmpty || userManager.user.password.isEmpty) {
                        print("Alert: Please complete the form!")
                    } else {
                        Task{
                            await imagePickerManager.uploadMedia()
                                
                                userManager.user.avatar = imagePickerManager.imageIds[0]
                                
                                if await userManager.createNewUser() {
                                    success = await userManager.authenticateUser()
                                }
                        }
                    }
                
            }).fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                .navigationDestination(isPresented: $success, destination: {
                    ProfileView().navigationBarBackButtonHidden(true)
                })
        }
    }
}


