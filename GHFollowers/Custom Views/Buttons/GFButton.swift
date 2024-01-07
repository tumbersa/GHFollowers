//
//  GFButton.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import UIKit

class GFButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor, title: String, systemImageName: String) {
        self.init(frame: .zero)
        set(color: color, title: title, systemImageName: systemImageName)
    }
    
    private func configure(){
        if #available(iOS 15.0, *) {
            configuration = .tinted()
            configuration?.cornerStyle = .medium
        } else {
            layer.cornerRadius      = 10
            titleLabel?.font        = UIFont.preferredFont(forTextStyle: .headline)
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func set(color: UIColor, title: String, systemImageName: String) {
        if #available(iOS 15.0, *) {
            configuration?.baseBackgroundColor  = color
            configuration?.baseForegroundColor  = color
            configuration?.title                = title
            
            configuration?.image                = UIImage(systemName: systemImageName)
            configuration?.imagePadding         = 6
            configuration?.imagePlacement       = .leading
        } else {
            backgroundColor = color
            setTitle(title, for: .normal)
        }
    }
}
