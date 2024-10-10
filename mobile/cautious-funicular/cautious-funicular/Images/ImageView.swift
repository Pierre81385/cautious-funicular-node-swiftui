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
    var iconWidth: Double
    var iconHeight: Double
    var icon: String
    
    var body: some View {
                                    PhotosPicker(
                                        selection: $imagePickerVM.selectedItems,
                                        maxSelectionCount: maxSelection,
                                        matching:  .any(of: [.images]),
                                        photoLibrary: .shared()) {
                                            Image(systemName: icon)
                                                .resizable()
                                                .fontWeight(.ultraLight)
                                                .foregroundStyle(.black)
                                                .frame(width: iconWidth, height: iconHeight)
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


