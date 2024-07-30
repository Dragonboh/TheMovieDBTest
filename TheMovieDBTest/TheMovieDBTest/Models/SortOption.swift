//
//  SortOptions.swift
//  TheMovieDBTest
//
//  Created by admin on 30.07.2024.
//

import Foundation

enum SortOption: SortByQuery {
    case popularity
    case title
    case rating
    
    var title: String {
        switch self {
        case .popularity:
            "BY popularity (default)"
        case .title:
            "By title"
        case .rating:
            "By rating"
        }
    }
    
    var queryValue: String {
        switch self {
        case .popularity:
            "popularity.desc"
        case .title:
            "title.asc"
        case .rating:
            "vote_average.desc"
        }
    }
}
