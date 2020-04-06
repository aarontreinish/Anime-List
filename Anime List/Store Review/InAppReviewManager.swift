//
//  InAppReviewManager.swift
//  Anime List
//
//  Created by Aaron Treinish on 4/5/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

class InAppReviewManager {

    // MARK: - Initializers
    init(storage: Storage = UserDefaults.standard, bundle: BundleType = Bundle.main) {
        self.storage = storage
        self.bundle = bundle
    }

    // MARK: - Public methods
    func shouldAskForReview() -> Bool {

        // Count the number of actions
        var actionCount = storage.integer(forKey: .actionCount)
        actionCount += 1
        storage.set(actionCount, forKey: .actionCount)

        // Store the day of first action
        let dateOfFirstActionObj = storage.object(forKey: .dayOfFirstAction)
        if dateOfFirstActionObj == nil {
            storage.set(NSDate(), forKey: .dayOfFirstAction)
        }

        // Calculate if there have been three days since the first action 604800
        let threeWeeksInSeconds: TimeInterval = 259200.0
        let threeWeeksAgo = Date(timeIntervalSinceNow: -threeWeeksInSeconds)

        guard let dateOfFirstAction = dateOfFirstActionObj as? Date else {
            return false
        }

        let comparisonResult = dateOfFirstAction.compare(threeWeeksAgo)

        // Check if user has reviewed this version
        let bundleVersionKey = kCFBundleVersionKey as String
        guard let bundleVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String else {
            return false
        }
        let lastVersion = storage.string(forKey: .lastVersionPromptedReview)

        guard case .orderedAscending = comparisonResult, actionCount >= 3, lastVersion == nil || lastVersion != bundleVersion else {
            return false
        }

        storage.set(bundleVersion, forKey: .lastVersionPromptedReview)
        return true
    }

    // MARK: - Private properties
    private let storage: Storage
    private let bundle: BundleType
}
