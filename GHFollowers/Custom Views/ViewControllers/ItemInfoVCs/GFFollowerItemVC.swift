//
//  GFFollowerItemVC.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 02.01.2024.
//

import UIKit

class GFFollowerItemVC: GFItemInfoVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfotype: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfotype: .following, withCount: user.following)
        actionButton.set(backgrounfColor: .systemGreen, title: "Get Followers")
    }
    
    override func actionButtonTapped() {
        delegate.didTapGetFollowers(for: user)
    }
}
