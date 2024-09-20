//
//  ChatModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//

import Foundation

struct ChatData: Decodable {
    var _id: String?
    var identifier: Int
    var participants: [String]
    var messages: [MessageData]
    var isPrivate: Bool
    var accessCode: Int
    var dateCreated: Date?
    var dateUpdated: Date?

    // Initializer with default values
    init(_id: String? = nil, identifier: Int = 0, participants: [String] = [], messages: [MessageData] = [], isPrivate: Bool = false, accessCode: Int = 0, dateCreated: Date? = nil, dateUpdated: Date? = nil) {
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

    // Date Formatter (if the date format needs customization)
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust the format to match your backend's date format
        return formatter
    }
}
