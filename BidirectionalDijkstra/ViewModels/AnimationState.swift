//
//  AnimationState.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

/// Observable state for managing pathfinding animation
@Observable
final class AnimationState {
    var exploredEdges: [(from: Int, to: Int)] = []
    var currentEdgeIndex: Int = 0
    var finalPath: [Int] = []
    var isAnimating: Bool = false
    var showFinalPath: Bool = false
    var exploredCount: Int = 0
    var distance: Double?
    var executionTime: TimeInterval?
    var exploredNodesCount: Int = 0
    
    // Store results per algorithm
    var storedResults: [PathfindingAlgorithm: StoredResult] = [
        .dijkstra: .empty,
        .bidirectional: .empty
    ]
    
    func reset() {
        exploredEdges = []
        currentEdgeIndex = 0
        finalPath = []
        isAnimating = false
        showFinalPath = false
        exploredCount = 0
        distance = nil
        executionTime = nil
        exploredNodesCount = 0
    }
    
    func resetAll() {
        reset()
        storedResults = [
            .dijkstra: .empty,
            .bidirectional: .empty
        ]
    }
    
    func saveResult(for algorithm: PathfindingAlgorithm) {
        storedResults[algorithm] = StoredResult(
            exploredEdges: exploredEdges,
            finalPath: finalPath,
            exploredCount: exploredEdges.count,
            exploredNodesCount: exploredNodesCount,
            distance: distance,
            executionTime: executionTime,
            hasRun: true
        )
    }
    
    func loadResult(for algorithm: PathfindingAlgorithm) {
        guard let stored = storedResults[algorithm], stored.hasRun else {
            reset()
            return
        }
        
        exploredEdges = stored.exploredEdges
        currentEdgeIndex = stored.exploredEdges.count
        finalPath = stored.finalPath
        isAnimating = false
        showFinalPath = true
        exploredCount = stored.exploredCount
        distance = stored.distance
        executionTime = stored.executionTime
        exploredNodesCount = stored.exploredNodesCount
    }
}

