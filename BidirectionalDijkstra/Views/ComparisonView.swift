//
//  ComparisonView.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import SwiftUI

/// Side-by-side comparison of both algorithms running simultaneously
struct ComparisonView: View {
    @State private var graph: Graph
    @State private var sourceNode: Int = 0
    @State private var targetNode: Int
    @State private var animationSpeed: AnimationSpeed = .normal
    
    @State private var dijkstraState = AnimationState()
    @State private var bidirectionalState = AnimationState()
    @State private var animationTimer: Timer?
    @State private var isRunning = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    init() {
        let initialGraph = MapGenerator.createMapGraph(width: 15, height: 20, spacing: 28)
        _graph = State(initialValue: initialGraph)
        _targetNode = State(initialValue: initialGraph.nodeCount - 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Maps - vertical on phone, horizontal on tablet/mac
                if isCompact {
                    VStack(spacing: 4) {
                        algorithmPanel(algorithm: .dijkstra, state: dijkstraState)
                        algorithmPanel(algorithm: .bidirectional, state: bidirectionalState)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack(spacing: 4) {
                        algorithmPanel(algorithm: .dijkstra, state: dijkstraState)
                        algorithmPanel(algorithm: .bidirectional, state: bidirectionalState)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                controlPanel
            }
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
    }
    
    private func algorithmPanel(algorithm: PathfindingAlgorithm, state: AnimationState) -> some View {
        VStack(spacing: 0) {
            CompactStatsView(algorithm: algorithm, state: state, isCompact: isCompact)
                .padding(.horizontal, 6)
                .padding(.top, 4)
            
            CompactMapView(
                graph: graph,
                animationState: state,
                sourceNode: sourceNode,
                targetNode: targetNode
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.1))
        .cornerRadius(8)
        .padding(4)
    }
    
    private var controlPanel: some View {
        VStack(spacing: 10) {
            // Speed picker
            HStack {
                Text("Speed:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Picker("Speed", selection: $animationSpeed) {
                    ForEach(AnimationSpeed.allCases, id: \.self) { speed in
                        Text(speed.rawValue).tag(speed)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 180)
            }
            
            HStack(spacing: 10) {
                Button(action: regenerateMap) {
                    Image(systemName: "map")
                    Text("Map")
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .disabled(isRunning)
                
                Button(action: randomizePoints) {
                    Image(systemName: "shuffle")
                    Text("Rand")
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .disabled(isRunning)
                
                Button(action: isRunning ? stopAnimation : runBothAlgorithms) {
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    Text(isRunning ? "Stop" : "Go")
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(isRunning ? .red : .green)
            }
            .font(.system(size: 13, weight: .medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
    }
    
    private func runBothAlgorithms() {
        dijkstraState.reset()
        bidirectionalState.reset()
        isRunning = true
        
        let dijkstraResult = Dijkstra.findPath(in: graph, from: sourceNode, to: targetNode)
        let bidirectionalResult = BidirectionalDijkstra.findPath(in: graph, from: sourceNode, to: targetNode)
        
        dijkstraState.exploredEdges = dijkstraResult.exploredEdges
        dijkstraState.finalPath = dijkstraResult.path
        dijkstraState.distance = dijkstraResult.distance.isFinite ? dijkstraResult.distance : nil
        dijkstraState.executionTime = dijkstraResult.executionTime
        let dijkstraTotalNodes = dijkstraResult.exploredNodes.count
        
        bidirectionalState.exploredEdges = bidirectionalResult.exploredEdges
        bidirectionalState.finalPath = bidirectionalResult.path
        bidirectionalState.distance = bidirectionalResult.distance.isFinite ? bidirectionalResult.distance : nil
        bidirectionalState.executionTime = bidirectionalResult.executionTime
        let bidirectionalTotalNodes = bidirectionalResult.exploredNodes.count
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationSpeed.tickInterval, repeats: true) { timer in
            var dijkstraDone = dijkstraState.currentEdgeIndex >= dijkstraState.exploredEdges.count
            var bidirectionalDone = bidirectionalState.currentEdgeIndex >= bidirectionalState.exploredEdges.count
            
            if !dijkstraDone {
                dijkstraState.currentEdgeIndex += animationSpeed.edgesPerTick
                dijkstraState.exploredCount = min(dijkstraState.currentEdgeIndex, dijkstraState.exploredEdges.count)
                let progress = Double(dijkstraState.currentEdgeIndex) / Double(max(1, dijkstraState.exploredEdges.count))
                dijkstraState.exploredNodesCount = Int(Double(dijkstraTotalNodes) * progress)
                
                if dijkstraState.currentEdgeIndex >= dijkstraState.exploredEdges.count {
                    dijkstraState.showFinalPath = true
                    dijkstraState.exploredNodesCount = dijkstraTotalNodes
                    dijkstraDone = true
                }
            }
            
            if !bidirectionalDone {
                bidirectionalState.currentEdgeIndex += animationSpeed.edgesPerTick
                bidirectionalState.exploredCount = min(bidirectionalState.currentEdgeIndex, bidirectionalState.exploredEdges.count)
                let progress = Double(bidirectionalState.currentEdgeIndex) / Double(max(1, bidirectionalState.exploredEdges.count))
                bidirectionalState.exploredNodesCount = Int(Double(bidirectionalTotalNodes) * progress)
                
                if bidirectionalState.currentEdgeIndex >= bidirectionalState.exploredEdges.count {
                    bidirectionalState.showFinalPath = true
                    bidirectionalState.exploredNodesCount = bidirectionalTotalNodes
                    bidirectionalDone = true
                }
            }
            
            if dijkstraDone && bidirectionalDone {
                isRunning = false
                timer.invalidate()
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        isRunning = false
        
        dijkstraState.currentEdgeIndex = dijkstraState.exploredEdges.count
        dijkstraState.exploredCount = dijkstraState.exploredEdges.count
        dijkstraState.showFinalPath = true
        
        bidirectionalState.currentEdgeIndex = bidirectionalState.exploredEdges.count
        bidirectionalState.exploredCount = bidirectionalState.exploredEdges.count
        bidirectionalState.showFinalPath = true
        
        let dijkstraResult = Dijkstra.findPath(in: graph, from: sourceNode, to: targetNode)
        let bidirectionalResult = BidirectionalDijkstra.findPath(in: graph, from: sourceNode, to: targetNode)
        dijkstraState.exploredNodesCount = dijkstraResult.exploredNodes.count
        bidirectionalState.exploredNodesCount = bidirectionalResult.exploredNodes.count
    }
    
    private func regenerateMap() {
        dijkstraState.reset()
        bidirectionalState.reset()
        graph = MapGenerator.createMapGraph(width: 15, height: 20, spacing: 28)
        sourceNode = 0
        targetNode = graph.nodeCount - 1
    }
    
    private func randomizePoints() {
        dijkstraState.reset()
        bidirectionalState.reset()
        sourceNode = Int.random(in: 0..<graph.nodeCount)
        repeat {
            targetNode = Int.random(in: 0..<graph.nodeCount)
        } while targetNode == sourceNode
    }
}

// MARK: - Compact Stats View

struct CompactStatsView: View {
    let algorithm: PathfindingAlgorithm
    let state: AnimationState
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            Text(algorithm == .dijkstra ? "DIJKSTRA" : "BIDIR")
                .font(.system(size: isCompact ? 10 : 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: isCompact ? 55 : 70, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: isCompact ? 6 : 10) {
                statPill(label: "E", value: "\(state.exploredCount)", color: .cyan)
                statPill(label: "N", value: "\(state.exploredNodesCount)", color: .orange)
                statPill(label: "D", value: state.distance.map { String(format: "%.0f", $0) } ?? "-", color: .green)
                statPill(label: "μs", value: state.executionTime.map { String(format: "%.0f", $0 * 1_000_000) } ?? "-", color: .purple)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.14))
        )
    }
    
    private func statPill(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

// MARK: - Compact Map View

struct CompactMapView: View {
    let graph: Graph
    let animationState: AnimationState
    let sourceNode: Int
    let targetNode: Int
    
    private let roadColor = Color(white: 0.25)
    private let exploredColor = Color.cyan
    private let pathColor = Color(red: 0.2, green: 1.0, blue: 0.4)
    private let sourceColor = Color.green
    private let targetColor = Color.red
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Calculate bounds of graph
                let minX = CGFloat(graph.nodes.map { $0.x }.min() ?? 0)
                let maxX = CGFloat(graph.nodes.map { $0.x }.max() ?? 1)
                let minY = CGFloat(graph.nodes.map { $0.y }.min() ?? 0)
                let maxY = CGFloat(graph.nodes.map { $0.y }.max() ?? 1)
                
                let graphWidth = maxX - minX + 40
                let graphHeight = maxY - minY + 40
                
                let scaleX = size.width / graphWidth
                let scaleY = size.height / graphHeight
                let scale = min(scaleX, scaleY) * 0.95
                
                let offsetX = (size.width - graphWidth * scale) / 2 - minX * scale + 20 * scale
                let offsetY = (size.height - graphHeight * scale) / 2 - minY * scale + 20 * scale
                
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                    .translatedBy(x: offsetX / scale, y: offsetY / scale)
                
                drawRoads(context: context, transform: transform)
                drawExploredEdges(context: context, transform: transform)
                drawFinalPath(context: context, transform: transform)
                drawMarkers(context: context, transform: transform, scale: scale)
            }
        }
    }
    
    private func drawRoads(context: GraphicsContext, transform: CGAffineTransform) {
        for node in graph.nodes {
            for edge in graph.neighbors(of: node.id) {
                guard edge.to < graph.nodes.count else { continue }
                let neighbor = graph.nodes[edge.to]
                let start = CGPoint(x: node.x, y: node.y).applying(transform)
                let end = CGPoint(x: neighbor.x, y: neighbor.y).applying(transform)
                
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                context.stroke(path, with: .color(roadColor), lineWidth: 1)
            }
        }
    }
    
    private func drawExploredEdges(context: GraphicsContext, transform: CGAffineTransform) {
        let visibleEdgeCount = animationState.currentEdgeIndex
        for i in 0..<min(visibleEdgeCount, animationState.exploredEdges.count) {
            let edge = animationState.exploredEdges[i]
            guard edge.from < graph.nodes.count && edge.to < graph.nodes.count else { continue }
            
            let fromNode = graph.nodes[edge.from]
            let toNode = graph.nodes[edge.to]
            let start = CGPoint(x: fromNode.x, y: fromNode.y).applying(transform)
            let end = CGPoint(x: toNode.x, y: toNode.y).applying(transform)
            
            var glowPath = Path()
            glowPath.move(to: start)
            glowPath.addLine(to: end)
            context.stroke(glowPath, with: .color(exploredColor.opacity(0.3)), lineWidth: 4)
            
            var mainPath = Path()
            mainPath.move(to: start)
            mainPath.addLine(to: end)
            context.stroke(mainPath, with: .color(exploredColor.opacity(0.8)), lineWidth: 2)
        }
    }
    
    private func drawFinalPath(context: GraphicsContext, transform: CGAffineTransform) {
        guard animationState.showFinalPath && animationState.finalPath.count > 1 else { return }
        
        for i in 0..<(animationState.finalPath.count - 1) {
            let fromId = animationState.finalPath[i]
            let toId = animationState.finalPath[i + 1]
            guard fromId < graph.nodes.count && toId < graph.nodes.count else { continue }
            
            let fromNode = graph.nodes[fromId]
            let toNode = graph.nodes[toId]
            let start = CGPoint(x: fromNode.x, y: fromNode.y).applying(transform)
            let end = CGPoint(x: toNode.x, y: toNode.y).applying(transform)
            
            var glowPath = Path()
            glowPath.move(to: start)
            glowPath.addLine(to: end)
            context.stroke(glowPath, with: .color(pathColor.opacity(0.5)), lineWidth: 6)
            
            var mainPath = Path()
            mainPath.move(to: start)
            mainPath.addLine(to: end)
            context.stroke(mainPath, with: .color(pathColor), lineWidth: 2.5)
        }
    }
    
    private func drawMarkers(context: GraphicsContext, transform: CGAffineTransform, scale: CGFloat) {
        let markerSize = max(8, 10 * scale)
        
        if sourceNode < graph.nodes.count {
            let source = graph.nodes[sourceNode]
            let point = CGPoint(x: source.x, y: source.y).applying(transform)
            let rect = CGRect(x: point.x - markerSize/2, y: point.y - markerSize/2, width: markerSize, height: markerSize)
            context.fill(Circle().path(in: rect), with: .color(sourceColor))
        }
        
        if targetNode < graph.nodes.count {
            let target = graph.nodes[targetNode]
            let point = CGPoint(x: target.x, y: target.y).applying(transform)
            let rect = CGRect(x: point.x - markerSize/2, y: point.y - markerSize/2, width: markerSize, height: markerSize)
            context.fill(Circle().path(in: rect), with: .color(targetColor))
        }
    }
}

#Preview {
    ComparisonView()
}
