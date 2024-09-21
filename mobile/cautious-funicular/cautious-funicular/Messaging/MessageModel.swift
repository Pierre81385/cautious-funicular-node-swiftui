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

    // Custom date decoder for Unix timestamps and ISO 8601 strings
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }

    // Decode date that could be in either Unix timestamp or ISO 8601 format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        sender = try container.decode(String.self, forKey: .sender)
        textContent = try container.decode(String.self, forKey: .textContent)
        mediaContent = try container.decode([String].self, forKey: .mediaContent)

        // Try decoding createdAt from multiple formats
        if let createdAtTimestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        } else if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
                  let date = MessageData.dateFormatter.date(from: createdAtString) {
            createdAt = date
        }
        
        // Try decoding updatedAt from multiple formats
        if let updatedAtTimestamp = try? container.decode(Double.self, forKey: .updatedAt) {
            updatedAt = Date(timeIntervalSince1970: updatedAtTimestamp)
        } else if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
                  let date = MessageData.dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        }
    }

    // Encode Date as Unix timestamp if present, or leave as ISO 8601 string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(sender, forKey: .sender)
        try container.encode(textContent, forKey: .textContent)
        try container.encode(mediaContent, forKey: .mediaContent)
        
        // Encode dates as Unix timestamps or ISO 8601 strings
        if let createdAt = createdAt {
            try container.encode(MessageData.dateFormatter.string(from: createdAt), forKey: .createdAt)
        }
        if let updatedAt = updatedAt {
            try container.encode(MessageData.dateFormatter.string(from: updatedAt), forKey: .updatedAt)
        }
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
