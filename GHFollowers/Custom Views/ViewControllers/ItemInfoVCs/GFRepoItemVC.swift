//
//  GFRepoItemVC.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 02.01.2024.
//

import UIKit

class GFRepoItemVC: GFItemInfoVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfotype: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfotype: .gists, withCount: user.publicGists)
        actionButton.set(backgrounfColor: .systemPurple, title: "Github Profile")
    }
}
