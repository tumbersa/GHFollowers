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
    
    func getFollowers(
        for username: String,
        page: Int,
        completion: @escaping (Result<[Follower], GFError>) -> Void) {
        let endPoint = baseUrl + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endPoint) else {
            completion(.failure(.invalidUsername))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, responce, error in
            if let _ = error {
                completion(.failure(.unableToComplete))
            }
            
            guard let responce = responce as? HTTPURLResponse,
                  responce.statusCode == 200 else {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completion(.success(followers))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
}
