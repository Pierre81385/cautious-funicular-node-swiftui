//
//  RecievedMessageView.swift
//  cautious-funicular
//
//  Created by m1_air on 10/10/24.
//

import Foundation
import SwiftUI

struct MessageFeed: View {
    var message: MessageData
    @State var userManager: UserVM = UserVM()
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    @State var userImageManager: ImagePickerVM = ImagePickerVM()

    
    // A Set to keep track of messages whose images have already been loaded
    @State private var loadedMessages: Set<String> = []

    var body: some View {
        VStack {
            // Display images if any are available
            if !imagePickerManager.images.isEmpty {
                // Use VStack to stack images vertically
                ForEach(imagePickerManager.images, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill() // Fill the frame while maintaining aspect ratio
                        .frame(width: 300) // Set a fixed height for each image
                        .cornerRadius(20) // Apply corner radius for rounded corners
                        .clipped() // Clip any overflowing parts
                        .rotationEffect(.degrees(180)) // Rotate the image 180 degrees
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 10) // Add some spacing between images
                }
                .padding()
            }

            // Text content of the message
            HStack {
                VStack(alignment: .leading) {
                    HStack{
                        if let avatar = userImageManager.images.first {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill() // Fill the frame while maintaining aspect ratio
                                .frame(width: 50, height: 50) // Set a fixed size for the circle
                                .clipShape(Circle()) // Make the image circular
                                .clipped() // Clip any overflowing parts
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .padding() // Add some spacing
                        }
                        Text(userManager.user.username).font(.headline)
                    }
                    Text(message.textContent)
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                Spacer()
            }
            .onAppear {
                Task {
                    if await userManager.fetchUser(byId: message.sender) {
                        
                    }
                    if await userImageManager.downloadMedia(byId: userManager.user.avatar) {
                        //
                    }
                    
                }
                
                // Check if images for this message have already been loaded
                if !loadedMessages.contains(message._id) {
                    // Load images for new messages
                    if !message.mediaContent.isEmpty {
                        for id in message.mediaContent {
                            Task {
                                await imagePickerManager.downloadMedia(byId: id)
                            }
                        }
                        // Mark this message as loaded
                        loadedMessages.insert(message._id)
                    }
                }
            }
        }
        .padding() // Add padding to the entire VStack
        .background(Color(UIColor.systemGroupedBackground)) // Match List background color
        .cornerRadius(10) // Optional: Add corner radius for the entire message
        //.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Optional: Add a subtle shadow
    }
}
