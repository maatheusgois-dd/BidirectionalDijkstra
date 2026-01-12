//
//  MapVisualizationView.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import SwiftUI

/// View responsible for rendering the graph visualization
struct MapVisualizationView: View {
    let graph: Graph
    let animationState: AnimationState
    let sourceNode: Int
    let targetNode: Int
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let roadColor = Color(white: 0.25)
    private let exploredColor = Color.cyan
    private let pathColor = Color(red: 0.2, green: 1.0, blue: 0.4)
    private let sourceColor = Color.green
    private let targetColor = Color.red
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                graphCanvas
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.08, blue: 0.1),
                Color(red: 0.12, green: 0.12, blue: 0.14)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var graphCanvas: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height / 2
            
            let transform = CGAffineTransform(translationX: centerX - 300, y: centerY - 350)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: offset.width / scale, y: offset.height / scale)
            
            drawRoads(context: context, transform: transform)
            drawExploredEdges(context: context, transform: transform)
            drawFinalPath(context: context, transform: transform)
            drawMarkers(context: context, transform: transform)
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = max(0.3, min(4.0, value))
                }
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
                .onEnded { _ in
                    lastOffset = offset
                }
        )
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
                context.stroke(path, with: .color(roadColor), lineWidth: 1.5)
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
            
            // Glow layer
            var glowPath = Path()
            glowPath.move(to: start)
            glowPath.addLine(to: end)
            context.stroke(glowPath, with: .color(exploredColor.opacity(0.3)), lineWidth: 6)
            
            // Main line
            var mainPath = Path()
            mainPath.move(to: start)
            mainPath.addLine(to: end)
            context.stroke(mainPath, with: .color(exploredColor.opacity(0.85)), lineWidth: 2.5)
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
            
            // Outer glow
            var glowPath = Path()
            glowPath.move(to: start)
            glowPath.addLine(to: end)
            context.stroke(glowPath, with: .color(pathColor.opacity(0.4)), lineWidth: 10)
            
            // Inner glow
            var innerGlow = Path()
            innerGlow.move(to: start)
            innerGlow.addLine(to: end)
            context.stroke(innerGlow, with: .color(pathColor.opacity(0.6)), lineWidth: 6)
            
            // Main path
            var mainPath = Path()
            mainPath.move(to: start)
            mainPath.addLine(to: end)
            context.stroke(mainPath, with: .color(pathColor), lineWidth: 3)
        }
    }
    
    private func drawMarkers(context: GraphicsContext, transform: CGAffineTransform) {
        // Source marker
        if sourceNode < graph.nodes.count {
            let source = graph.nodes[sourceNode]
            let point = CGPoint(x: source.x, y: source.y).applying(transform)
            
            let glowRect = CGRect(x: point.x - 14, y: point.y - 14, width: 28, height: 28)
            context.fill(Circle().path(in: glowRect), with: .color(sourceColor.opacity(0.4)))
            
            let rect = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
            context.fill(Circle().path(in: rect), with: .color(sourceColor))
        }
        
        // Target marker
        if targetNode < graph.nodes.count {
            let target = graph.nodes[targetNode]
            let point = CGPoint(x: target.x, y: target.y).applying(transform)
            
            let glowRect = CGRect(x: point.x - 14, y: point.y - 14, width: 28, height: 28)
            context.fill(Circle().path(in: glowRect), with: .color(targetColor.opacity(0.4)))
            
            let rect = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
            context.fill(Circle().path(in: rect), with: .color(targetColor))
        }
    }
}

