//
//  Strinng + Extentions.swift
//  TheMovieDBTest
//
//  Created by admin on 06.08.2024.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}
