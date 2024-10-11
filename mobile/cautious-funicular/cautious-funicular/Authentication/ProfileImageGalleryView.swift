//
//  ProfileImageGalleryView.swift
//  cautious-funicular
//
//  Created by m1_air on 10/10/24.
//

import SwiftUI

struct ImageGalleryView: View {
    var images: [String]
    @State var imagePickerManager: ImagePickerVM = ImagePickerVM()
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack{
            ScrollView(content: {
                if !imagePickerManager.images.isEmpty {
                    // Use VStack to stack images vertically
                    ForEach(imagePickerManager.images, id: \.self) { img in
                        if img.size.width > img.size.height {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill() // Fill the frame while maintaining aspect ratio
                                .frame(width: screenWidth*0.9) // Set a fixed height for each image
                                .cornerRadius(20) // Apply corner radius for rounded corners
                                .clipped() // Clip any overflowing parts
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, 20) // Add padding to left and right to prevent images from reaching edges
                                .padding(.vertical, 10) // Add padding to top and bottom of each image
                        } else {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill() // Fill the frame while maintaining aspect ratio
                                .frame(height: screenWidth*0.9) // Set a fixed height for each image
                                .cornerRadius(20) // Apply corner radius for rounded corners
                                .clipped() // Clip any overflowing parts
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, 20) // Add padding to left and right to prevent images from reaching edges
                                .padding(.vertical, 10) // Add padding to top and bottom of each image
                        }
                    }
                }
            })
            .padding(.horizontal, 20) // Add padding to the ScrollView to keep content away from sheet edges
        }
        .onAppear{
            for img in images {
                Task{
                    await imagePickerManager.downloadMedia(byId: img)
                }
            }
        }
    }
}

//#Preview {
//    ProfileImageGalleryView()
//}
