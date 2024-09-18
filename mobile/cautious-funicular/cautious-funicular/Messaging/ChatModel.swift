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
    
    init(_id: String? = nil, identifier: Int = 0, participants: [String] = [], messages: [MessageData] = [], isPrivate: Bool = false, accessCode: Int = 0) {
        self._id = _id
        self.identifier = identifier
        self.participants = participants
        self.messages = messages
        self.isPrivate = isPrivate
        self.accessCode = accessCode
    }

    // Custom CodingKeys if JSON keys differ from property names
    enum CodingKeys: String, CodingKey {
        case _id
        case identifier
        case participants
        case messages
        case isPrivate
        case accessCode
    }
}
