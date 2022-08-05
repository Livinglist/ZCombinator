//
//  StoryType.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/18/22.
//

import Foundation

enum StoryType: String, Equatable, CaseIterable {
    case top = "top"
    case best = "best"
    case new = "new"
    case ask = "ask"
    case show = "show"
    case jobs = "job"
    
    var iconName: String {
        switch self {
        case .top:
            return "flame"
        case .best:
            return "triangle.tophalf.filled"
        case .new:
            return "rectangle.dashed"
        case .ask:
            return "person.fill.questionmark"
        case .show:
            return "sparkles.tv"
        case .jobs:
            return "briefcase"
        }
    }
}
