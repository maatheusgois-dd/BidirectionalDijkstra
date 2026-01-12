//
//  PathfindingView.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import SwiftUI

/// Main view orchestrating pathfinding visualization (Composition Root)
struct PathfindingView: View {
    @State private var graph: Graph
    @State private var selectedAlgorithm: PathfindingAlgorithm = .bidirectional
    @State private var sourceNode: Int = 0
    @State private var targetNode: Int
    @State private var animationState = AnimationState()
    @State private var animationSpeed: AnimationSpeed = .normal
    @State private var animationTimer: Timer?
    
    init() {
        let initialGraph = MapGenerator.createMapGraph(width: 20, height: 25, spacing: 28)
        _graph = State(initialValue: initialGraph)
        _targetNode = State(initialValue: initialGraph.nodeCount - 1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            StatsHeaderView(algorithm: selectedAlgorithm, animationState: animationState)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            MapVisualizationView(
                graph: graph,
                animationState: animationState,
                sourceNode: sourceNode,
                targetNode: targetNode
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ControlPanelView(
                selectedAlgorithm: $selectedAlgorithm,
                animationSpeed: $animationSpeed,
                isAnimating: animationState.isAnimating,
                onAlgorithmChange: { algorithm in
                    animationState.loadResult(for: algorithm)
                },
                onNewMap: regenerateMap,
                onRandomPoints: randomizePoints,
                onRunStop: {
                    if animationState.isAnimating {
                        stopAnimation()
                    } else {
                        runAnimatedAlgorithm()
                    }
                }
            )
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.1))
    }
    
    private func runAnimatedAlgorithm() {
        animationState.reset()
        animationState.isAnimating = true
        
        let result = selectedAlgorithm.findPath(in: graph, from: sourceNode, to: targetNode)
        
        animationState.exploredEdges = result.exploredEdges
        animationState.finalPath = result.path
        animationState.distance = result.distance.isFinite ? result.distance : nil
        animationState.executionTime = result.executionTime
        
        let totalNodes = result.exploredNodes.count
        let currentAlgorithm = selectedAlgorithm
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationSpeed.tickInterval, repeats: true) { timer in
            if animationState.currentEdgeIndex < animationState.exploredEdges.count {
                animationState.currentEdgeIndex += animationSpeed.edgesPerTick
                animationState.exploredCount = min(animationState.currentEdgeIndex, animationState.exploredEdges.count)
                let progress = Double(animationState.currentEdgeIndex) / Double(max(1, animationState.exploredEdges.count))
                animationState.exploredNodesCount = Int(Double(totalNodes) * progress)
            } else {
                animationState.showFinalPath = true
                animationState.isAnimating = false
                animationState.exploredNodesCount = totalNodes
                animationState.saveResult(for: currentAlgorithm)
                timer.invalidate()
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        animationState.isAnimating = false
        
        animationState.currentEdgeIndex = animationState.exploredEdges.count
        animationState.exploredCount = animationState.exploredEdges.count
        animationState.showFinalPath = true
        
        let result = selectedAlgorithm.findPath(in: graph, from: sourceNode, to: targetNode)
        animationState.exploredNodesCount = result.exploredNodes.count
        
        animationState.saveResult(for: selectedAlgorithm)
    }
    
    private func regenerateMap() {
        animationState.resetAll()
        graph = MapGenerator.createMapGraph(width: 20, height: 25, spacing: 28)
        sourceNode = 0
        targetNode = graph.nodeCount - 1
    }
    
    private func randomizePoints() {
        animationState.resetAll()
        sourceNode = Int.random(in: 0..<graph.nodeCount)
        repeat {
            targetNode = Int.random(in: 0..<graph.nodeCount)
        } while targetNode == sourceNode
    }
}

#Preview {
    PathfindingView()
}

