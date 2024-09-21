//
//  ChatModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//
import Foundation

struct ChatData: Codable {
    var _id: String?
    var identifier: Double
    var participants: [String]
    var messages: [MessageData]
    var isPrivate: Bool
    var accessCode: Int
    var dateCreated: Date?
    var dateUpdated: Date?

    // Initializer with default values
    init(_id: String? = nil, identifier: Double = 0, participants: [String] = [], messages: [MessageData] = [], isPrivate: Bool = false, accessCode: Int = 0, dateCreated: Date? = nil, dateUpdated: Date? = nil) {
        self._id = _id
        self.identifier = identifier
        self.participants = participants
        self.messages = messages
        self.isPrivate = isPrivate
        self.accessCode = accessCode
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }

    // Custom CodingKeys if JSON keys differ from property names
    enum CodingKeys: String, CodingKey {
        case _id
        case identifier
        case participants
        case messages
        case isPrivate
        case accessCode
        case dateCreated
        case dateUpdated
    }

    // Custom date decoder for Unix timestamps and ISO 8601 strings
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }

    // Decode date that could be in either Unix timestamp or ISO 8601 format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        identifier = try container.decode(Double.self, forKey: .identifier)
        participants = try container.decode([String].self, forKey: .participants)
        messages = try container.decode([MessageData].self, forKey: .messages)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        accessCode = try container.decode(Int.self, forKey: .accessCode)

        // Decode dateCreated: try Unix timestamp first, then ISO 8601 string
        if let dateCreatedTimestamp = try? container.decode(Double.self, forKey: .dateCreated) {
            dateCreated = Date(timeIntervalSince1970: dateCreatedTimestamp)
        } else if let dateCreatedString = try? container.decode(String.self, forKey: .dateCreated),
                  let date = ChatData.dateFormatter.date(from: dateCreatedString) {
            dateCreated = date
        }

        // Decode dateUpdated: try Unix timestamp first, then ISO 8601 string
        if let dateUpdatedTimestamp = try? container.decode(Double.self, forKey: .dateUpdated) {
            dateUpdated = Date(timeIntervalSince1970: dateUpdatedTimestamp)
        } else if let dateUpdatedString = try? container.decode(String.self, forKey: .dateUpdated),
                  let date = ChatData.dateFormatter.date(from: dateUpdatedString) {
            dateUpdated = date
        }
    }

    // Encode Date as Unix timestamp or ISO 8601 string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(participants, forKey: .participants)
        try container.encode(messages, forKey: .messages)
        try container.encode(isPrivate, forKey: .isPrivate)
        try container.encode(accessCode, forKey: .accessCode)
        
        // Encode dates as ISO 8601 strings
        if let dateCreated = dateCreated {
            try container.encode(ChatData.dateFormatter.string(from: dateCreated), forKey: .dateCreated)
        }
        if let dateUpdated = dateUpdated {
            try container.encode(ChatData.dateFormatter.string(from: dateUpdated), forKey: .dateUpdated)
        }
    }
}
