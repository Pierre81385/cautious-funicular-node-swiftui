//
//  ChatViewModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/16/24.
//

import Foundation
import Observation

@Observable class ChatVM {
    var chat: ChatData = ChatData()
    var chats: [ChatData] = []
    var baseURL: String = "http://127.0.0.1:3000/chats"
    var error: String = ""
    
    func createNewChat() async -> Bool {
            guard let url = URL(string: "\(baseURL)/new") else { return false }

            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Prepare the JSON body
            let body: [String: Any] = [
                "identifier": chat.identifier,
                "participants": chat.participants,
                "messages": chat.messages,
                "isPrivate": chat.isPrivate,
                "accessCode": chat.accessCode
            ]

            // Convert body to JSON data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return false}

            request.httpBody = jsonData

            do {
                // Perform the request
                let (_, response) = try await URLSession.shared.data(for: request)

                // Ensure we received an HTTP 200 response
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    return true
                } else {
                    self.error = "Error: \(response)"
                    return false
                }
            } catch {
                self.error = "Error submitting data: \(error.localizedDescription)"
                return false

            }
        }
}

//self.identifier = identifier
//self.participants = participants
//self.messages = messages
//self.isPrivate = isPrivate
//self.accessCode = accessCode
