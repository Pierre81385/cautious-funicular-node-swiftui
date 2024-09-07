//
//  UserViewModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/6/24.
//

import Foundation
import Observation

@Observable class UserVM {
    var user: UserData = UserData()
    var users: [UserData] = []
    var isSubmitted = false
    var baseURL: String = "http://127.0.0.1:3000/users"

    
    func createNewUser() async {
            guard let url = URL(string: "\(baseURL)/new") else { return }

            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Prepare the JSON body
            let body: [String: Any] = [
                "username": user.username,
                "email": user.email,
                "password": user.password
            ]

            // Convert body to JSON data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }

            request.httpBody = jsonData

            do {
                // Perform the request
                let (data, response) = try await URLSession.shared.data(for: request)

                // Ensure we received an HTTP 200 response
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Data submitted successfully")
                    DispatchQueue.main.async {
                        self.isSubmitted = true
                    }
                } else {
                    print("Error: \(response)")
                }
            } catch {
                print("Error submitting data: \(error.localizedDescription)")
            }
        }
    
    func authenticateUser() async -> Bool {
        
        //a very basic authentication
        
        guard let url = URL(string: "\(baseURL)/user/\(user.username)") else { return false }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedUser = try JSONDecoder().decode(UserData.self, from: data)
                print("found user \(decodedUser.username)")
                if (user.password == decodedUser.password) {
                    SocketService.shared.socket.emit("authenticated", [ "username": decodedUser.username ])
                    return true
                }
                
            } else {
                print("Error: Invalid cridentials")
                return false
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return false
        }
        
        return false
    }
    
    func fetchUser(byId userId: String) async -> UserData? {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedUser = try JSONDecoder().decode(UserData.self, from: data)
                return decodedUser
            } else {
                print("Error: Invalid response")
                return nil
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAllUsers() async throws -> [UserData] {
        guard let url = URL(string: "\(baseURL)/") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let users = try JSONDecoder().decode([UserData].self, from: data)
        return users
    }

    
    func updateUser(userId: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "username": user.username,
            "email": user.email,
            "password": user.password
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return false }

        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("User updated successfully")
                return true
            } else {
                print("Error: Invalid response")
                return false
            }
        } catch {
            print("Error updating user: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteUser(byId userId: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("User deleted successfully")
                return true
            } else {
                print("Error: Invalid response")
                return false
            }
        } catch {
            print("Error deleting user: \(error.localizedDescription)")
            return false
        }
    }

}
