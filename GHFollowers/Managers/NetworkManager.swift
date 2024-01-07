//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import UIKit

class NetworkManager {
    
    static let shared   = NetworkManager()
    private let baseUrl = "https://api.github.com/users/"
    let cache           = NSCache<NSString, UIImage>()
    let decoder         = JSONDecoder()
    
    private init() {
        decoder.keyDecodingStrategy     = .convertFromSnakeCase
        decoder.dateDecodingStrategy    = .iso8601
    }
    
// MARK: - iOS 13.0
    @available(iOS 13.0, *)
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
    
    @available(iOS 15.0, *)
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        let endPoint = baseUrl + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endPoint) else {
            throw GFError.invalidUsername
        }
        
        let (data,responce) = try await URLSession.shared.data(from: url)
        
        guard let responce = responce as? HTTPURLResponse,
                responce.statusCode == 200 else {
            throw GFError.invalidResponce
        }
            
            
        do {
            return try decoder.decode([Follower].self, from: data)
        } catch {
            throw GFError.invalidData
        }
                
    }
    
    @available(iOS 13.0, *)
    func getUserInfo(
        for username: String,
        completion: @escaping (Result<User, GFError>) -> Void) {
        let endPoint = baseUrl + "\(username)"
        
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
                let decoder                     = JSONDecoder()
                decoder.keyDecodingStrategy     = .convertFromSnakeCase
                decoder.dateDecodingStrategy    = .iso8601
                let user = try decoder.decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    @available(iOS 15.0, *)
    func getUserInfo(for username: String) async throws -> User {
        let endPoint = baseUrl + "\(username)"
        
        guard let url = URL(string: endPoint) else { throw GFError.invalidUsername }
        let (data,responce) = try await URLSession.shared.data(from: url)
        guard let responce = responce as? HTTPURLResponse,
              responce.statusCode == 200 else {
            throw GFError.invalidResponce
        }
        
        do {
            return try decoder.decode(User.self, from: data)
        } catch {
            throw GFError.invalidData
        }
    }
    
    @available(iOS 13.0, *)
    func downloadImage(from urlString: String, complition: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            complition(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            complition(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, responce, error in
            guard let self, 
                error == nil,
                let responce = responce as? HTTPURLResponse,
                responce.statusCode == 200,
                let data,
                let image = UIImage(data: data) else {
                complition(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            complition(image)
        }
        task.resume()
    }
    
    @available(iOS 15.0, *)
    func downloadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) { return image }
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            self.cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
}
