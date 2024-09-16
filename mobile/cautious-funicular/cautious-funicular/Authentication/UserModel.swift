//
//  UserModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/6/24.
//

import Foundation

struct UserData: Codable {
    var _id: String?
    var online: Bool
    var username: String
    var email: String
    var password: String
    var dateCreated: Date?
    var dateUpdated: Date?

    private enum CodingKeys: String, CodingKey {
        case _id
        case online
        case username
        case email
        case password
        case dateCreated
        case dateUpdated
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
        try container.encode(online, forKey: .online)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encodeIfPresent(dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(dateUpdated, forKey: .dateUpdated)
    }

    // Decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        online = try container.decode(Bool.self, forKey: .online)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
    }
    
    init(_id: String = "", online: Bool = false, username: String = "", email: String = "", password: String = "", dateCreated: Date? = nil, dateUpdated: Date? = nil) {
            self._id = _id
            self.online = online
            self.username = username
            self.email = email
            self.password = password
            self.dateCreated = dateCreated
            self.dateUpdated = dateUpdated
        }
}
