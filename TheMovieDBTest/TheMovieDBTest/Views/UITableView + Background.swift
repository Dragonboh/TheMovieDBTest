//
//  UITableView + Background.swift
//  TheMovieDBTest
//
//  Created by admin on 03.08.2024.
//

import Foundation
import UIKit

extension UITableView {
    enum TableViewBackground {
        case empty
        case failedToLoad
    }
    
    func configure(backgroundView: TableViewBackground?) {
        switch backgroundView {
        case .empty:
            self.backgroundView = .contentEmptyView
        case .failedToLoad:
            self.backgroundView = .contentUnavailableView
        case .none:
            self.backgroundView = nil
        }
    }
}
