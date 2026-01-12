//
//  Graph.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

final class Graph {
    var nodes: [GraphNode]
    private var adjacencyList: [[Edge]]
    
    init(nodeCount: Int) {
        self.nodes = []
        self.adjacencyList = Array(repeating: [], count: nodeCount)
    }
    
    func addNode(_ node: GraphNode) {
        if node.id >= adjacencyList.count {
            adjacencyList.append(contentsOf: Array(repeating: [], count: node.id - adjacencyList.count + 1))
        }
        nodes.append(node)
    }
    
    func addEdge(from: Int, to: Int, weight: Double) {
        adjacencyList[from].append(Edge(to: to, weight: weight))
    }
    
    func addBidirectionalEdge(from: Int, to: Int, weight: Double) {
        addEdge(from: from, to: to, weight: weight)
        addEdge(from: to, to: from, weight: weight)
    }
    
    func neighbors(of node: Int) -> [Edge] {
        return adjacencyList[node]
    }
    
    var nodeCount: Int { adjacencyList.count }
}

