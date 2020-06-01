//
//  ReviewService.swift
//  Anime List
//
//  Created by Aaron Treinish on 6/1/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation
import StoreKit

class ReviewService {
    
    private init() {}
    static let shared = ReviewService()
    
    private let defaults = UserDefaults.standard
    
    private var lastRequest: Date? {
        get {
            return defaults.value(forKey: "ReviewService.lastRequest") as? Date
        } set {
            defaults.set(newValue, forKey: "ReviewService.lastRequest")
        }
    }
    
    private var oneWeekAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    }
    
    private var shouldRequestReview: Bool {
        if lastRequest == nil {
            return true
        } else if let lastRequest = self.lastRequest, lastRequest < oneWeekAgo {
            return true
        }
        return false
    }
    
    func requestReview() {
        guard shouldRequestReview else { return }
        SKStoreReviewController.requestReview()
        lastRequest = Date()
    }
    
}
