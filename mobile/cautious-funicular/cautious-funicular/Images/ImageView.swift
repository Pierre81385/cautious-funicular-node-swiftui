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
    @Binding var imagePickerVM: ImagePickerVM
    var maxSelection: Int
    
    var body: some View {
                                    PhotosPicker(
                                        selection: $imagePickerVM.selectedItems,
                                        matching:  .any(of: [.images]),
                                        photoLibrary: .shared()) {
                                            Image(systemName: "person.crop.circle.badge.plus")
                                                .resizable()
                                                .fontWeight(.ultraLight)
                                                .foregroundStyle(.black)
                                                .frame(width: 120, height: 100)
                                        }.onAppear{
                                            imagePickerVM.selectedItems = []
                                        }
                                        .onChange(of: imagePickerVM.selectedItems) { oldItems, newItems in
                                            imagePickerVM.images = []
                                            Task {
                                                    await imagePickerVM.loadMedia(from: newItems)
                                                }
                                            
                                        }
    }
}



