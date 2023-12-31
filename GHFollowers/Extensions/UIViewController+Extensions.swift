//
//  UIViewController.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import UIKit
import SafariServices


extension UIViewController {
    
    func presentGFAlert(title: String, message: String, buttonTitle: String, isQueueUnused: Bool = true){
        if isQueueUnused {
            presentGFAlertOnly(title: title, message: message, buttonTitle: buttonTitle)
        } else {
            DispatchQueue.main.async {
                self.presentGFAlertOnly(title: title, message: message, buttonTitle: buttonTitle)
            }
        }
    }
    
    private func presentGFAlertOnly (title: String, message: String, buttonTitle: String){
        let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle  = .overFullScreen
        alertVC.modalTransitionStyle    = .crossDissolve
        self.present(alertVC, animated: true)
    }
    
    func presentDefaultError() {
        let alertVC = GFAlertVC(title: "Something went wrong",
                                message: "We were unable to complete your task at this time. Please try again",
                                buttonTitle: "Ok")
        alertVC.modalPresentationStyle  = .overFullScreen
        alertVC.modalTransitionStyle    = .crossDissolve
        present(alertVC, animated: true)
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemGreen
        present(safariVC, animated: true)
    }
    
   
}
