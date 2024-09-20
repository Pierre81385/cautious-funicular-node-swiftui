//
//  MessageModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//

import Foundation

struct MessageData: Codable, Equatable {
    var _id: String
    var sender: String
    var textContent: String
    var mediaContent: [String]
    var createdAt: Date?
    var updatedAt: Date?

    private enum CodingKeys: String, CodingKey {
        case _id
        case sender
        case textContent
        case mediaContent
        case createdAt
        case updatedAt
    }

    // Custom date decoder
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust to your format
        return formatter
    }

    // Encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(sender, forKey: .sender)
        try container.encode(textContent, forKey: .textContent)
        try container.encode(mediaContent, forKey: .mediaContent)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }

    // Decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        sender = try container.decode(String.self, forKey: .sender)
        textContent = try container.decode(String.self, forKey: .textContent)
        mediaContent = try container.decode([String].self, forKey: .mediaContent)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
    
    // Init method with default values
    init(
        id: String = UUID().uuidString,
        sender: String = "",
        textContent: String = "",
        mediaContent: [String] = [],
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self._id = id
        self.sender = sender
        self.textContent = textContent
        self.mediaContent = mediaContent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}



