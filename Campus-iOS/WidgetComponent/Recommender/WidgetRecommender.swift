//
//  WidgetRecommender.swift
//  Campus-iOS
//
//  Created by Robyn Kölle on 24.07.22.
//

import Foundation
import SwiftUI

@MainActor
class WidgetRecommender: ObservableObject {
    
    @Published var status: WidgetRecommenderStatus
    @Published var recommendations: [WidgetRecommendation]
    
    private let strategy: WidgetRecommenderStrategy
    private let model: Model
    
    init(strategy: WidgetRecommenderStrategy, model: Model) {
        self.strategy = strategy
        self.model = model
        self.status = .loading
        self.recommendations = []
    }
    
    func fetchRecommendations() async throws {
        let recommendations = try await strategy.getRecommendation().sorted(by: { $0.priority > $1.priority })
        self.recommendations = recommendations
        self.status = .success
    }
}

enum WidgetRecommenderStatus {
    case loading, success
}
