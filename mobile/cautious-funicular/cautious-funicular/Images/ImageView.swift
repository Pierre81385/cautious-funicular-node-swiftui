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

    var body: some View {
                                    PhotosPicker(
                                        selection: $imagePickerVM.selectedItems,
                                        matching:  .any(of: [.images]),
                                        photoLibrary: .shared()) {
                                            Image(systemName: "person.crop.circle.badge.plus")
                                                .fontWeight(.ultraLight)
                                                .foregroundStyle(.black)
                                                //.frame(width: 60, height: 50)
                                        }.onAppear{
                                            imagePickerVM.selectedItems = []
                                        }
                                        .onChange(of: imagePickerVM.selectedItems) { oldItems, newItems in
                                            Task {
                                                    await imagePickerVM.loadMedia(from: newItems)
                                                }
                                            
                                        }
    }
}

//#Preview {
//    MediaPickerView()
//}
