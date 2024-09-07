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
    @State var message: String = "Hello, World"
    
    var body: some View {
        VStack{
            Toggle("I'm a new user.", isOn: $new).padding()
            if(new) {
                TextField("Email", text: $userManager.user.email).padding()
            }
            TextField("Username", text: $userManager.user.username).padding()
            SecureField("Password", text: $userManager.user.password).padding()
            if(new) {
                SecureField("Verify Password", text: $verifyPassword).padding()
            }
            Button("Submit", action: {
                if(new) {
                    if(userManager.user.email.isEmpty || userManager.user.username.isEmpty || userManager.user.password.isEmpty) {
                        print("Show Alert")
                    } else {
                        Task{
                            await userManager.createNewUser()
                        }
                    }
                } else {
                    Task{
                        await userManager.authenticateUser()
                    }
                }
            })
            Text(message).fontWeight(.ultraLight).padding()
        }.onChange(of: SocketService.shared.message, {
            message = SocketService.shared.message
        })
    }
}

#Preview {
    UserView()
}
