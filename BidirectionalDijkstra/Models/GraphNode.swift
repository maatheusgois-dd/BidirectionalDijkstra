//
//  GraphNode.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

struct GraphNode: Identifiable {
    let id: Int
    var x: Double
    var y: Double
    var neighbors: [Edge]
    
    init(id: Int, x: Double, y: Double, neighbors: [Edge] = []) {
        self.id = id
        self.x = x
        self.y = y
        self.neighbors = neighbors
    }
}

