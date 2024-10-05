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
                                        .onChange(of: imagePickerVM.images, { oldValue, newValue in
                                                Task{
                                                    await imagePickerVM.uploadMedia()
                                                }
                                        })
    }
}

//#Preview {
//    MediaPickerView()
//}
