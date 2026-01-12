//
//  AnimationSpeed.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

enum AnimationSpeed: String, CaseIterable {
    case slow = "0.5x"
    case normal = "1x"
    case fast = "2x"
    case veryFast = "4x"
    
    var edgesPerTick: Int {
        switch self {
        case .slow: return 1
        case .normal: return 3
        case .fast: return 8
        case .veryFast: return 20
        }
    }
    
    var tickInterval: TimeInterval {
        return 0.016 // ~60fps
    }
}

