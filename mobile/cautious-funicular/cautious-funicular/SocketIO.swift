//
//  SocketIO.swift
//  cautious-funicular
//
//  Created by m1_air on 9/5/24.
//

import Foundation
import SocketIO
import Observation

enum SocketConfig {
    static let development_url = "http://127.0.0.1:3000"
}

@Observable class SocketService {
    
    var message: String = ""
    static let shared = SocketService()
    private let manager: SocketManager
    let socket: SocketIOClient
    
    var confirmedServerConnection: Bool = false
    var userListUpdateRequired: Bool = false
    var updateChatMessages: Double?
     
    private init() {
        let url = URL(string: SocketConfig.development_url)!
        manager = SocketManager(socketURL: url, config: [.log(true), .forceWebsockets(true)])
        socket = manager.defaultSocket
        setupSocketConnection()
    }
    
    private func setupSocketConnection() {
        
        socket.on(clientEvent: .connect) { data, ack in
            self.message = "Mobile Socket connected"
            self.confirmedServerConnection = true
        }
        
        socket.on("updateUsersList") { data, ack in
            self.message = "User logged on or off."
            self.userListUpdateRequired = true
        }
        
        socket.on("updateChat") { data, ack in
            self.message = "update messages"
            if let chatData = data.first as? [String: Any] {
                    if let identifier = chatData["identifier"] as? Double {
                        self.updateChatMessages = identifier
                        print("double \(self.updateChatMessages)")
                    } else {
                        self.message = "Chat identifier is not a Double."
                    }
                } else {
                    self.message = "Invalid chat data received."
                }
        }
    }
        //socket.connect()
    
    
    deinit {
            //socket.disconnect()
        }
}
