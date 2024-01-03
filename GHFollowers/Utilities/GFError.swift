//
//  ErrorMessage.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 31.12.2023.
//

import Foundation

enum GFError: String, Error {
    case invalidUsername    = "This username created an invalid requset. Please try again"
    case unableToComplete   = "Unable to complete your request. Please check your internet connection."
    case invalidResponce    = "Invalid responce from the server. Please try again."
    case invalidData        = "The data received from the server was invalid. Please try again."
    case unableToFavotite   = "There was an error favoriting this user. Please try again"
    case alreadyInFavorites = "You've already favorited this user. You must like them"
}
