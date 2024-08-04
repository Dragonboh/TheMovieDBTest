//
//  File.swift
//  TheMovieDBTest
//
//  Created by admin on 04.08.2024.
//

import UIKit

extension UITableViewDiffableDataSource {
    var isEmpty: Bool {
        snapshot().isEmpty
    }
    
    var numberOfItems: Int {
        snapshot().numberOfItems
    }
}

extension NSDiffableDataSourceSnapshot {
    var isEmpty: Bool {
        numberOfItems == 0
    }
}
