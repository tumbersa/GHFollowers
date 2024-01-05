//
//  UITableView+Extensions.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 05.01.2024.
//

import UIKit

extension UITableView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async { self.reloadData() }
    }
    
    func removeExcessCells() {
        tableFooterView = UIView(frame: .zero)
    }
}
