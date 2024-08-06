//
//  TableHeaderView.swift
//  TheMovieDBTest
//
//  Created by admin on 06.08.2024.
//

import UIKit

class TableOfflineHeaderView: UIView {
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "You are offline. This is offline search. Pull to refresh"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .lightGray
        addSubview(errorMessageLabel)
        
        NSLayoutConstraint.activate([
            errorMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorMessageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16)
        ])
    }
}
