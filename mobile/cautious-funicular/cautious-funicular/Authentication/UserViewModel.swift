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

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "identifier": generateUserIdentifier(user.username),
                "online": user.online,
                "username": user.username,
                "email": user.email,
                "password": user.password,
                "avatar": user.avatar,
                "uploads": user.uploads,
                "longitude": user.longitude,
                "latitude": user.latitude
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return false}

            request.httpBody = jsonData

            do {
                let (_, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
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
        
        guard let url = URL(string: "\(baseURL)/user/login") else { return false }
        print("Sending request to \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the login payload (assuming `user` has `username` and `password` properties)
        let loginPayload = [
            "username": user.username,
            "password": user.password
        ]

        do {
            // Convert the login payload to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: loginPayload)
            request.httpBody = jsonData

            // Send the request using URLSession
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Parse the response to the LoginResponse struct
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    // Handle successful login, e.g., set user and JWT token
                    self.user._id = loginResponse.user  // Assuming `user` has an `id` property
                    let jwtToken = loginResponse.jwt
                    
                    // Optionally, store the JWT in UserDefaults or Keychain for later use
                    UserDefaults.standard.set(jwtToken, forKey: "userToken")
                    
                    print("Login successful! JWT Token: \(jwtToken)")
                    return true
                } else if httpResponse.statusCode == 409 {
                    self.error = "Username or password is incorrect."
                    print(self.error)
                } else if httpResponse.statusCode == 404 {
                    self.error = "User not found."
                    print(self.error)
                } else {
                    self.error = "Unexpected error: \(httpResponse.statusCode)"
                    print(self.error)
                }
            }
        } catch {
            self.error = "Error: \(error.localizedDescription)"
            print(self.error)
            return false
        }
        
        return false
    }
    
    func fetchUser(byId userId: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return false }
        
        // Retrieve the JWT token from UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            self.error = "Error: No token found."
            return false
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedUser = try JSONDecoder().decode(UserData.self, from: data)
                self.user = decodedUser
                return true
            } else {
                self.error = "Error: No user found with that ID."
                return false
            }
        } catch {
            self.error = "Error fetching user: \(error.localizedDescription)"
            return false
        }
    }
    
    func fetchAllUsers() async -> Bool {
        guard let url = URL(string: "\(baseURL)/") else {
            self.error = "Invalid URL."
            return false
        }
        
        // Retrieve the JWT token from UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            self.error = "Error: No token found."
            return false
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Ensure response is of type HTTPURLResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                self.error = "Error: Invalid response format."
                return false
            }

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
        } catch {
            self.error = "Error fetching users: \(error.localizedDescription)"
            return false
        }
    }
    
    func updateUser(userUpdate: UserData) async -> Bool {
        print("Updating user!")
        guard let url = URL(string: "\(baseURL)/\(userUpdate._id ?? "NoUser")") else { return false }
        
        // Retrieve the JWT token from UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            self.error = "Error: No token found."
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "online": userUpdate.online,
            "username": userUpdate.username,
            "email": userUpdate.email,
            "password": userUpdate.password,
            "avatar": userUpdate.avatar,
            "uploads": userUpdate.uploads,
            "longitude": userUpdate.longitude,
            "latitude": userUpdate.latitude
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
        
        // Retrieve the JWT token from UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            self.error = "Error: No token found."
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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

struct LoginResponse: Codable {
    let message: String
    let user: String  // Assuming the user is just the user ID (u._id)
    let jwt: String
}
