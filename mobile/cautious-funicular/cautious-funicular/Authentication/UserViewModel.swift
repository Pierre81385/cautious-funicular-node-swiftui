//
//  UserViewModel.swift
//  cautious-funicular
//
//  Created by m1_air on 9/6/24.
//

import Foundation
import Observation
import CryptoKit

@Observable class UserVM {
    var user: UserData = UserData()
    var users: [UserData] = []
    var baseURL: String = "http://127.0.0.1:3000/users"
    var error: String = ""
    
    func createNewUser() async -> Bool {
            print("Creating a new user.")
            guard let url = URL(string: "\(baseURL)/new") else { return false }

            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Prepare the JSON body
            let body: [String: Any] = [
                "identifier": generateUserIdentifier(user.username),
                "online": user.online,
                "username": user.username,
                "email": user.email,
                "password": user.password,
                "avatar": user.avatar,
                "uploads": user.uploads
            ]

            // Convert body to JSON data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return false}

            request.httpBody = jsonData

            do {
                // Perform the request
                let (_, response) = try await URLSession.shared.data(for: request)

                // Ensure we received an HTTP 200 response
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("New user successfully added to MongoDB.")
                    return true
                } else {
                    self.error = "Error: \(response)"
                    print(self.error)
                    return false
                }
            } catch {
                self.error = "Error submitting data: \(error.localizedDescription)"
                print(self.error)
                return false

            }
        }
    
    let max12DigitNumber: UInt64 = 1_000_000_000_000
    
    func generateUserIdentifier(_ username: String) -> UInt64 {
        // Convert the username to UTF-8 data
        let data = Data(username.utf8)
        
        // Compute the SHA-256 hash of the username
        let hash = SHA256.hash(data: data)
        
        // Get the first 8 bytes of the hash
        let hashPrefix = Array(hash.prefix(8))
        
        // Convert the first 8 bytes to a UInt64
        var result: UInt64 = 0
        for byte in hashPrefix {
            result = (result << 8) | UInt64(byte)
        }
        
        // Limit the result to 12 digits using modulo
        return result % max12DigitNumber
    }
    
    func authenticateUser() async -> Bool {
        print("Attempting to authenticate a user.")
        //a very basic authentication
        
        guard let url = URL(string: "\(baseURL)/user/\(user.username)") else { return false }
        print("Sending request to \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            print(response)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print(httpResponse)
                let decodedUser = try JSONDecoder().decode(UserData.self, from: data)
                if (user.password == decodedUser.password) {
                    self.user = decodedUser
                    print("User authenticated by password match!")
                    return true
                }
                
            } else {
                self.error = "Error: Invalid cridentials"
                print(self.error)
                return false
            }
        } catch {
            self.error = "Error fetching user: \(error.localizedDescription)"
            print(self.error)
            return false
        }
        
        return false
    }
    
    func fetchUser(byId userId: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return false }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedUser = try JSONDecoder().decode(UserData.self, from: data)
                self.user = decodedUser
            } else {
                self.error = "Error: No user found with that ID."
                return false
            }
        } catch {
            self.error = "Error fetching user: \(error.localizedDescription)"
            return false
        }
        
        return false
    }
    
    func fetchAllUsers() async -> Bool {
        guard let url = URL(string: "\(baseURL)/") else {
            self.error = "Invalid URL."
            return false
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let decodedUsers = try JSONDecoder().decode([UserData].self, from: data)
                        self.users = decodedUsers
                        return true
                    } catch {
                        self.error = "Error decoding users: \(error.localizedDescription)"
                        return false
                    }
                } else {
                    self.error = "Error: Unexpected status code \(httpResponse.statusCode)."
                    return false
                }
            } else {
                self.error = "Error: Invalid response format."
                return false
            }
        } catch {
            self.error = "Error fetching users: \(error.localizedDescription)"
            return false
        }
    }

    
    func updateUser(userUpdate: UserData) async -> Bool {
        print("Updating user!")
        guard let url = URL(string: "\(baseURL)/\(userUpdate._id ?? "NoUser")") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "online": userUpdate.online,
            "username": userUpdate.username,
            "email": userUpdate.email,
            "password": userUpdate.password,
            "avatar": userUpdate.avatar,
            "uploads": userUpdate.uploads
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return false }

        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                self.error = "Error: Invalid response"
                return false
            }
        } catch {
            self.error = "Error updating user: \(error.localizedDescription)"
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
                self.error = "User deleted successfully"
                return true
            } else {
                self.error = "Error: Invalid response"
                return false
            }
        } catch {
            self.error = "Error deleting user: \(error.localizedDescription)"
            return false
        }
    }

}
