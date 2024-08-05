//
//  TableFooterView.swift
//  TheMovieDBTest
//
//  Created by admin on 05.08.2024.
//

import UIKit

class TableFooterLoadingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .purple
        activityIndicator.startAnimating()

        self.addSubview(activityIndicator)
        self.backgroundColor = .red
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableFooterErrorView: UIView {
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Error occurred loading next page, tap button to retry"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .gray
        addSubview(errorMessageLabel)
        addSubview(retryButton)
        NSLayoutConstraint.activate([
            errorMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorMessageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            retryButton.leadingAnchor.constraint(equalTo: errorMessageLabel.trailingAnchor, constant: 16),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            retryButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 100),
            retryButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
