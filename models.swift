//
//  models.swift
//  
//
//  Created by Jonas on 16/07/2026.
//

import Foundation

struct HackatimeStats: Codable {
    let totalSeconds: Double
    let totalMinutes: Double
    let totalHours: Double
    let dailyAverage: Double
    let languages: [StatItem]
    let projects: [StatItem]
    let editors: [StatItem]
    
    enum CodingKeys: String, CodingKey {
        case totalSconds = "total_seconds"
        case totalMinutes= "total_minutes"
    }
