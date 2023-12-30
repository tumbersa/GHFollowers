//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import Foundation

class NetworkManager {
    static let shared   = NetworkManager()
    let baseUrl         = "https://api.github.com/users/"
    
    private init() {}
    
    func getFollowers(for username: String, page: Int,completion: @escaping ([Follower]?, String?) -> Void) {
        let endPoint = baseUrl + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endPoint) else {
            completion(nil,"This username created an invalid requset. Please try again")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, responce, error in
            if let _ = error {
                completion(nil, "Unable to complete your request. Please check your internet connection.")
            }
            
            guard let responce = responce as? HTTPURLResponse,
                  responce.statusCode == 200 else {
                completion(nil, "Invalid responce from the server. Please try again.")
                return
            }
            
            guard let data else {
                completion(nil, "The data received from the server was invalid. Please try again.")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completion(followers, nil)
            } catch {
                completion(nil, "The data received from the server was invalid. Please try again.")
            }
        }
        
        task.resume()
    }
}
