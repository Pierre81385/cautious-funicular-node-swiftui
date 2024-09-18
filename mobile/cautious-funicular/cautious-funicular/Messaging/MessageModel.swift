//
//  MessageModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//

import Foundation

struct MessageData: Codable {
    var id: Int
    var sender: String
    var textContent: String
    var mediaContent: [String]
    var dateCreated: Date?
    
    init(
        id: Int = 0,
        sender: String = "",
        textContent: String = "",
        mediaContent: [String] = [],
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.sender = sender
        self.textContent = textContent
        self.mediaContent = mediaContent
        self.dateCreated = dateCreated
    }
}


