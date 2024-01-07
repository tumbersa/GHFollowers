//
//  Date+Extensions.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 02.01.2024.
//

import Foundation

extension Date {
    func converteToMonthYearFormat() -> String {
        guard #available(iOS 15.0, *) else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"
            return dateFormatter.string(from: self)
        }
        
        return formatted(.dateTime.month(.wide).year())
    }
}

