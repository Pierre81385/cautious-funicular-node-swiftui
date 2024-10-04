//
//  ImageView.swift
//  cautious-funicular
//
//  Created by m1_air on 9/24/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct MediaPickerView: View {
    @Binding var imagePickerVM: ImagePickerViewModel
    @Binding var showImagePicker: Bool

    var body: some View {
        ScrollView(content: {
            VStack {
                if (showImagePicker) {
                    Rectangle()
                                .fill(Color.white)
                                .frame(width: 325, height: 325)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .overlay(
                                    PhotosPicker(
                                        selection: $imagePickerVM.selectedItems,
                                        matching:  .any(of: [.images]),
                                        photoLibrary: .shared()) {
                                            Image(systemName: "person.crop.circle.badge.plus").resizable()
                                                .fontWeight(.ultraLight)
                                                .foregroundStyle(.black)
                                                .frame(width: 60, height: 50)
                                        }
                                        .onChange(of: imagePickerVM.selectedItems) { oldItems, newItems in

                                            Task {
                                                    await imagePickerVM.loadMedia(from: newItems)
                                                }
                                            
                                        }
//                                        .onChange(of: imagePickerVM.images) {
//                                            if !imagePickerVM.images.isEmpty {
//                                                showImagePicker = false
//                                            }
//                                        }
                                )
                }

                if !imagePickerVM.images.isEmpty {
                    HStack{
                        Button(action: {
                            imagePickerVM.selectedItems = []
                            imagePickerVM.images = []
                            showImagePicker = true
                        }, label: {
                            Text("Cancel")
                        })
                        Spacer()
                        Button(action: {
                            Task{
                                await imagePickerVM.uploadMedia()
                            }
                            showImagePicker = false
                        }, label: {
                            Text("Upload")
                        })
                    }
                        ForEach(imagePickerVM.images, id: \.self) { image in
                            
                            Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 320, height: 320)
                                        .cornerRadius(20)
                                        .clipped() // Ensures the image doesn't overflow outside the rounded corners
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                }
            }
            .padding()
        })
      
    }
}

//#Preview {
//    MediaPickerView()
//}
