//
//  CustomError.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import Foundation

enum CustomError: Error {
    case error(String)
    
    var errorMessage: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}
