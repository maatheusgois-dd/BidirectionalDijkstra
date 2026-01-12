//
//  PathfindingAlgorithm.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

/// Protocol defining a pathfinding algorithm
protocol PathfindingAlgorithmProtocol {
    static func findPath(in graph: Graph, from source: Int, to target: Int) -> PathResult
}

/// Enum for selecting pathfinding algorithms
enum PathfindingAlgorithm: String, CaseIterable {
    case dijkstra = "DIJKSTRA"
    case bidirectional = "BIDIRECTIONAL DIJKSTRA"
    
    func findPath(in graph: Graph, from source: Int, to target: Int) -> PathResult {
        switch self {
        case .dijkstra:
            return Dijkstra.findPath(in: graph, from: source, to: target)
        case .bidirectional:
            return BidirectionalDijkstra.findPath(in: graph, from: source, to: target)
        }
    }
}

