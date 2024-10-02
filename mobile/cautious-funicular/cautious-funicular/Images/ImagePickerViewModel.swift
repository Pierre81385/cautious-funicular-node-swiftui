//
//  ImageViewModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/24/24.
//

import Foundation
import Observation
import PhotosUI
import _PhotosUI_SwiftUI

@Observable class ImagePickerViewModel {
    var selectedItems: [PhotosPickerItem] = []
    var images: [UIImage] = []
    
    func loadMedia(from items: [PhotosPickerItem]) async {
        for item in items {
            // Load the media as either Data (images)
            if let imageData = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: imageData) {
                images.append(image)
            }
        }
    }
}
