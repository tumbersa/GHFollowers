//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 31.12.2023.
//

import UIKit
import SwiftUI

class FollowerCell: UICollectionViewCell {
    static let reuseID  = "FollowerCell"
    
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let usernameLabel   = GFTitleLabel(textAlignment: .center, fontSize: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }
    
    func set(follower: Follower) {
        if #available(iOS 16.0, *) {
            contentConfiguration = UIHostingConfiguration {
                FollowerView(follower: follower)
            }
        } else {
            avatarImageView.image = nil
        avatarImageView.kf.setImage(with: URL(string: follower.avatarUrl))
        usernameLabel.text = follower.login
    }
    }
    
    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        avatarImageView.image = Images.placeholder
        let padding: CGFloat = 8
        
        if #available(iOS 15.0, *) {
            NSLayoutConstraint.activate([
                avatarImageView.topAnchor.constraint(equalTo: topAnchor,constant: padding),
                avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
                
                usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
                usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                usernameLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        } else {
            NSLayoutConstraint.activate([
                avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: padding),
                avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
                avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
                
                usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
                usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
                usernameLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
    }
}
