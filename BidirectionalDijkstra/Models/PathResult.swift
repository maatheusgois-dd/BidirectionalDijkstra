//
//  PathResult.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

struct PathResult {
    let distance: Double
    let path: [Int]
    let exploredNodes: Set<Int>
    let exploredEdges: [(from: Int, to: Int)]
    let executionTime: TimeInterval
    
    static let notFound = PathResult(
        distance: .infinity,
        path: [],
        exploredNodes: [],
        exploredEdges: [],
        executionTime: 0
    )
}

