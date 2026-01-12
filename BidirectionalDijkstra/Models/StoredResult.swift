//
//  StoredResult.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

struct StoredResult {
    var exploredEdges: [(from: Int, to: Int)]
    var finalPath: [Int]
    var exploredCount: Int
    var exploredNodesCount: Int
    var distance: Double?
    var executionTime: TimeInterval?
    var hasRun: Bool
    
    static let empty = StoredResult(
        exploredEdges: [],
        finalPath: [],
        exploredCount: 0,
        exploredNodesCount: 0,
        distance: nil,
        executionTime: nil,
        hasRun: false
    )
}

