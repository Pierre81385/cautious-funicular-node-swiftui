//
//  ImageModel.swift
//  cautious-funicular
//
//  Created by m1_air on 10/4/24.
//

import Foundation

struct ImageData: Codable {
    var _id: String // Matches 'id' field in the Mongoose schema
    var img: Image // Matches the 'img' field, which contains 'data' and 'contentType'

    // Nested struct to represent the 'img' field in the Mongoose schema
    struct Image: Codable {
        var data: Data // Corresponds to 'data' (Buffer) in the Mongoose schema
        var contentType: String // Corresponds to 'contentType' in the Mongoose schema

        // Custom initializer to create an Image object from base64 string and content type
        init(base64Data: String, contentType: String) {
            self.data = Data(base64Encoded: base64Data) ?? Data() // Decode base64 string to Data
            self.contentType = contentType
        }

        // Enum for custom decoding
        enum CodingKeys: String, CodingKey {
            case data
            case contentType
        }

        // Custom decoder to handle binary data (Buffer) as a base64-encoded string
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let base64String = try container.decode(String.self, forKey: .data)
            self.data = Data(base64Encoded: base64String) ?? Data()
            self.contentType = try container.decode(String.self, forKey: .contentType)
        }
    }

    // Initializer for ImageData
    init(_id: String, base64Data: String, contentType: String) {
        self._id = _id
        self.img = Image(base64Data: base64Data, contentType: contentType) // Use the custom Image initializer
    }
}
