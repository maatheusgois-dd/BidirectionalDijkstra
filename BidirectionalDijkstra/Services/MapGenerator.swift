//
//  MapGenerator.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

/// Service responsible for generating map graphs
struct MapGenerator {
    
    /// Creates a grid-like road network similar to a real map
    static func createMapGraph(width: Int, height: Int, spacing: Double = 30) -> Graph {
        let graph = Graph(nodeCount: width * height)
        
        // Create nodes in a grid pattern with some randomization
        for y in 0..<height {
            for x in 0..<width {
                let id = y * width + x
                let jitterX = Double.random(in: -spacing * 0.2...spacing * 0.2)
                let jitterY = Double.random(in: -spacing * 0.2...spacing * 0.2)
                
                let node = GraphNode(
                    id: id,
                    x: Double(x) * spacing + jitterX + spacing,
                    y: Double(y) * spacing + jitterY + spacing
                )
                graph.addNode(node)
            }
        }
        
        // Create edges (roads) with random weights
        for y in 0..<height {
            for x in 0..<width {
                let id = y * width + x
                
                // Connect to right neighbor
                if x < width - 1 {
                    let rightId = y * width + (x + 1)
                    let weight = euclideanDistance(graph.nodes[id], graph.nodes[rightId])
                    graph.addBidirectionalEdge(from: id, to: rightId, weight: weight)
                }
                
                // Connect to bottom neighbor
                if y < height - 1 {
                    let bottomId = (y + 1) * width + x
                    let weight = euclideanDistance(graph.nodes[id], graph.nodes[bottomId])
                    graph.addBidirectionalEdge(from: id, to: bottomId, weight: weight)
                }
                
                // Diagonal connections (some roads)
                if x < width - 1 && y < height - 1 && Bool.random() {
                    let diagId = (y + 1) * width + (x + 1)
                    let weight = euclideanDistance(graph.nodes[id], graph.nodes[diagId])
                    graph.addBidirectionalEdge(from: id, to: diagId, weight: weight)
                }
            }
        }
        
        return graph
    }
    
    private static func euclideanDistance(_ a: GraphNode, _ b: GraphNode) -> Double {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}

