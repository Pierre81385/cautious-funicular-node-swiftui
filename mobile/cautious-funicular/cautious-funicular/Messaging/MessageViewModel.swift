////
////  MessageViewModel.swift
////  cautious-funicular
////
////  Created by m1_air on 9/20/24.
////
//
//import Foundation
//import Observation
//
//@Observable class MessageViewModel {
//    var message: MessageData = MessageData()
//    var baseURL: String = "http://127.0.0.1:3000/message"
//    var error: String = ""
//    
//    func sendMessage() async -> Bool {
//        guard let url = URL(string: "\(baseURL)/send") else { return false }
//        print("sending new message to \(url)")
//
//        // Create the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // Ensure mediaContent is a valid array of strings
//        let body: [String: Any] = [
//            "chat": message.chat, // Make sure chat matches the server expectation (int vs. number)
//            "sender": message.sender,
//            "textContent": message.textContent,
//            "mediaContent": message.mediaContent // Ensure this is [String]
//        ]
//        
//        // Convert body to JSON data
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
//            self.error = "Error serializing request body."
//            return false
//        }
//
//        request.httpBody = jsonData
//        
//        do {
//            // Perform the request
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Ensure we received an HTTP 200 response
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                // Check if there's data to decode (ensure server returns valid JSON)
//                if !data.isEmpty {
//                    let decodedMessage = try JSONDecoder().decode(MessageData.self, from: data)
//                    self.message = decodedMessage
//                } else {
//                    print("No data returned from server")
//                }
//                print(message)
//                return true
//            } else {
//                self.error = "Error: Invalid response. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)"
//                print(self.error)
//                return false
//            }
//        } catch {
//            self.error = "Error submitting data: \(error.localizedDescription)"
//            print(self.error)
//            return false
//        }
//    }
//
//    
//    func fetchMessage(byId messageId: String) async -> Bool {
//        guard let url = URL(string: "\(baseURL)/\(messageId)") else { return false }
//        
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                let decodedChatMessage = try JSONDecoder().decode(MessageData.self, from: data)
//                self.message = decodedChatMessage
//                return true
//            } else {
//                self.error = "Error: No message found by that ID."
//                return false
//            }
//        } catch {
//            self.error = "Error fetching chat: \(error.localizedDescription)"
//            return false
//        }
//        
//    }
//
//}
//
