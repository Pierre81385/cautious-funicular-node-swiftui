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
    var imageIds: [String] = []
    var isUploading: Bool = false
    var isDownloading: Bool = false
    var baseURL: String = "http://localhost:3000/imgs"
    var error: String = ""
    
    func loadMedia(from items: [PhotosPickerItem]) async {
        images = []
        for item in items {
            // Load the media as either Data (images)
            if let imageData = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: imageData) {
                images.append(image)
            }
        }
    }
    
    func downloadMedia(byId imageId: String) async -> Bool {
        isDownloading = true
        images = []
        defer { isDownloading = false }
        
        guard let url = URL(string: "\(baseURL)/\(imageId)") else { return false }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Decode the entire ImageData object
                let decodedImageData = try JSONDecoder().decode(ImageData.self, from: data)
                
                // Convert the decoded image data to UIImage and append it to the images array
                if let uiImage = UIImage(data: decodedImageData.img.data) {
                    self.images.append(uiImage)
                    print("Image found!")
                    return true
                } else {
                    self.error = "Error: Unable to convert data to UIImage."
                    print(error)
                    return false
                }
            } else {
                self.error = "Error: No image found by id \(imageId)"
                print(error)
                return false
            }
        } catch {
            self.error = "Error fetching image: \(error.localizedDescription)"
            print(error)
            return false
        }
    }
    
    func uploadMedia() async {
        isUploading = true
        defer { isUploading = false } // Reset the uploading state when done

        for image in images {
            // Convert UIImage to Data
            guard let imageData = image.jpegData(compressionQuality: 0.2) else {
                print("Error: Could not convert UIImage to Data")
                continue
            }

            // Create URLRequest
            guard let url = URL(string: "http://localhost:3000/imgs/upload") else {
                print("Error: Invalid URL")
                continue
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // Create multipart form body
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            var body = Data()

            // Add image data to the form
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            // Set the request body
            request.httpBody = body

            do {
                // Send the request with async URLSession
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Check if the response is successful
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Parse the response data
                    if let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let imageId = responseObject["imageId"] as? String {
                        // Append the image ID to the ViewModel's array
                        DispatchQueue.main.async {
                            self.imageIds.append(imageId)  // Save the image ID
                        }
                    } else {
                        print("Error: Unable to parse response")
                    }
                } else {
                    print("Server error: \(response)")
                }
            } catch {
                // Handle networking errors
                print("Upload failed with error: \(error)")
            }
        }
    }
}
