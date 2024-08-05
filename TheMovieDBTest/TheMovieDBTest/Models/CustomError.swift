//
//  CustomError.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import Foundation

enum CustomError: Error {
    case error(String)
    case noInternetConnection
    
    var errorMessage: String {
        switch self {
        case .error(let message):
            return message
        case .noInternetConnection:
            return "You are offline. Please, enable your Wi-Fi or connect using cellular data"
        }
    }
}
