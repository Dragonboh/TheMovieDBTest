//
//  MovieModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

struct Response<RR: Codable>: Codable {
    let results: [RR]
}

struct MovieModel: Codable {
    let id: Int
    let backdropPath: String
    let title: String
    let releaseDate: String
    let rating: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case backdropPath = "backdrop_path"
        case title = "original_title"
        case releaseDate = "release_date"
        case rating = "vote_average"
    }
}

struct MoviewModelMock {
    let id: Int
    let title: String
    let releaseDate: String
    let rating: Double
    let image: String
    
    static let moviesMockArray = [
        MoviewModelMock(id: 573435, title: "Bad Boys: Ride or Die", releaseDate: "2024-06-05", rating: 7.511, image: "badBoys"),
        MoviewModelMock(id: 573435, title: "Bad Boys: Ride or Die", releaseDate: "2024-06-05", rating: 7.511, image: "badBoys"),
        MoviewModelMock(id: 573435, title: "Bad Boys: Ride or Die", releaseDate: "2024-06-05", rating: 7.511, image: "badBoys"),
        MoviewModelMock(id: 573435, title: "Bad Boys: Ride or Die", releaseDate: "2024-06-05", rating: 7.511, image: "badBoys"),
        MoviewModelMock(id: 573435, title: "Bad Boys: Ride or Die", releaseDate: "2024-06-05", rating: 7.511, image: "badBoys")
    ]
}
