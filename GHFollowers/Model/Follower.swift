//
//  Follower.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import Foundation

struct Follower: Codable, Hashable {
    var login: String
    var avatarUrl: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(login)
    }
}
