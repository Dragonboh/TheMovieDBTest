//
//  Genre.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation


enum AllGenre: Int, Codable {
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case mystery = 9648
    case romance = 10749
    case scienceFiction = 878
    case tvMovie = 10770
    case thriller = 53
    case war = 10752
    case western = 37
    
    var name: String {
        switch self {
        case .action:
            "Action"
        case .adventure:
            "Adventure"
        case .animation:
            "Animation"
        case .comedy:
            "Comedy"
        case .crime:
            "Crime"
        case .documentary:
            "Documentary"
        case .drama:
            "Drama"
        case .family:
            "Family"
        case .fantasy:
            "Fantasy"
        case .history:
            "History"
        case .horror:
            "Horror"
        case .music:
            "Music"
        case .mystery:
            "Mystery"
        case .romance:
            "Romance"
        case .scienceFiction:
            "ScienceFiction"
        case .tvMovie:
            "TvMovie"
        case .thriller:
            "Thriller"
        case .war:
            "War"
        case .western:
            "Western"
        }
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}


