//
//  UIView+Extensions.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 04.01.2024.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...){
        for view in views {
            addSubview(view)
        }
    }
}
