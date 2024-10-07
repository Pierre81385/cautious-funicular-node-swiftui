//
//  UserModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/6/24.
//

import Foundation

struct UserData: Codable, Equatable {
    var _id: String?
    var identifier: Double
    var online: Bool
    var username: String
    var email: String
    var password: String
    var avatar: String
    var uploads: [String]
    var dateCreated: Date?
    var dateUpdated: Date?

    private enum CodingKeys: String, CodingKey {
        case _id
        case identifier
        case online
        case username
        case email
        case password
        case avatar
        case uploads
        case dateCreated
        case dateUpdated
    }

    // Decode Unix timestamp as Date
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        identifier = try container.decode(Double.self, forKey: .identifier)
        online = try container.decode(Bool.self, forKey: .online)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        avatar = try container.decode(String.self, forKey: .avatar)
        uploads = try container.decode([String].self, forKey: .uploads)
        
        // Try decoding dateCreated and dateUpdated as Unix timestamps
        if let dateCreatedTimestamp = try container.decodeIfPresent(Double.self, forKey: .dateCreated) {
            dateCreated = Date(timeIntervalSince1970: dateCreatedTimestamp)
        }
        if let dateUpdatedTimestamp = try container.decodeIfPresent(Double.self, forKey: .dateUpdated) {
            dateUpdated = Date(timeIntervalSince1970: dateUpdatedTimestamp)
        }
    }

    // Encode Date as Unix timestamp
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(online, forKey: .online)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(uploads, forKey: .uploads)
        
        // Encode dates as Unix timestamps (seconds since 1970)
        if let dateCreated = dateCreated {
            try container.encode(dateCreated.timeIntervalSince1970, forKey: .dateCreated)
        }
        if let dateUpdated = dateUpdated {
            try container.encode(dateUpdated.timeIntervalSince1970, forKey: .dateUpdated)
        }
    }
    
    // Init method with default values
    init(_id: String = "", identifier: Double = 0, online: Bool = false, username: String = "", email: String = "", password: String = "", avatar: String = "", uploads: [String] = [], dateCreated: Date? = nil, dateUpdated: Date? = nil) {
        self._id = _id
        self.identifier = identifier
        self.online = online
        self.username = username
        self.email = email
        self.password = password
        self.avatar = avatar
        self.uploads = uploads
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
}
