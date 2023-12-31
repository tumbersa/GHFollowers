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
    
    func getFollowers(for username: String, page: Int,completion: @escaping ([Follower]?, ErrorMessage?) -> Void) {
        let endPoint = baseUrl + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endPoint) else {
            completion(nil, .invalidUsername)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, responce, error in
            if let _ = error {
                completion(nil, .unableToComplete)
            }
            
            guard let responce = responce as? HTTPURLResponse,
                  responce.statusCode == 200 else {
                completion(nil, .invalidResponce)
                return
            }
            
            guard let data else {
                completion(nil, .invalidData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completion(followers, nil)
            } catch {
                completion(nil, .invalidData)
            }
        }
        
        task.resume()
    }
}
