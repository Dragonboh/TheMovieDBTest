//
//  File.swift
//  TheMovieDBTest
//
//  Created by admin on 03.08.2024.
//

import UIKit
import SwiftUI

extension UIView {
    static var contentUnavailableView: UIView = {
        UIHostingController(rootView: ContentUnavailableView(.init("Movies unavailable"),
                                                             systemImage: "xmark.icloud",
                                                             description: Text("Pull down to refresh"))).view
    }()
    
    static var contentEmptyView: UIView = {
        UIHostingController(rootView: ContentUnavailableView(.init("No movies"),
                                                             systemImage: "arrow.clockwise.icloud",
                                                             description: Text("Pull down to refresh"))).view
    }()
}

@available(iOS 17.0, *)
#Preview {
    UIView.contentEmptyView
}

@available(iOS 17.0, *)
#Preview {
    UIView.contentUnavailableView
}
