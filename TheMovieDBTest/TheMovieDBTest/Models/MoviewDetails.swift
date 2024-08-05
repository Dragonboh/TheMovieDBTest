//
//  MoviewDetails.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import Foundation

struct MovieDetails: Codable {
    let id: Int
    let posterPath: String?
    let country: [String]?
    let releaseDate: String?
    let title: String?
    let originalTitle: String?
    let rating: Double?
    let videos: MovieResults?
    let overview: String?
    let genres: [Genre]?
    let backdropPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, videos, overview, genres
        case posterPath = "poster_path"
        case country = "origin_country"
        case releaseDate = "release_date"
        case originalTitle = "original_title"
        case rating = "vote_average"
        case backdropPath = "backdrop_path"
    }
    
    static let movieDetailsSample = MovieDetails(id: 0, posterPath: "", country: [], releaseDate: "", title: "", originalTitle: "", rating: 0.0, videos: nil, overview: "", genres: [], backdropPath: "")
}

struct MovieResults: Codable {
    let results: [MovieVideo]
}

struct MovieVideo: Codable {
    let id: String
    let type: String
    let site: String
    let key: String
    let name: String
}
