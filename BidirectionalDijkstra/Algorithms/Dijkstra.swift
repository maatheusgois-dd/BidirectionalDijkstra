//
//  Dijkstra.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

// MARK: - Dijkstra's Algorithm
//
// ══════════════════════════════════════════════════════════════════════════════
// MATHEMATICAL FOUNDATION
// ══════════════════════════════════════════════════════════════════════════════
//
// Dijkstra's algorithm solves the Single-Source Shortest Path (SSSP) problem:
//
//   Given a weighted graph G = (V, E) with non-negative edge weights w: E → R⁺,
//   find the shortest path from source s to all other vertices.
//
// INVARIANT (Greedy Property):
//   When a vertex u is extracted from the priority queue, d[u] = δ(s, u),
//   where δ(s, u) is the true shortest distance from s to u.
//
// PROOF SKETCH:
//   By contradiction. Suppose u is the first vertex for which d[u] ≠ δ(s, u).
//   Let p = s → ... → x → y → ... → u be the true shortest path.
//   Since w ≥ 0, when u is extracted: d[y] ≤ d[u] (y comes before u on path).
//   But y was processed before u (smaller distance), so d[y] = δ(s, y).
//   Then d[u] would have been updated via y. Contradiction.
//
// RELAXATION:
//   For edge (u, v) with weight w(u,v):
//   if d[u] + w(u,v) < d[v]:
//       d[v] = d[u] + w(u,v)     // Triangle inequality optimization
//       π[v] = u                  // Record predecessor for path reconstruction
//
// COMPLEXITY:
//   • Time:  O((V + E) log V) with binary heap priority queue
//   • Space: O(V) for distances, predecessors, and visited set
//
// The algorithm explores nodes in "wavefront" fashion, expanding outward
// from the source like ripples in water. Each ripple represents a distance
// level, and nodes are finalized in order of their distance from source.
//
// ══════════════════════════════════════════════════════════════════════════════

/// Classic Dijkstra's algorithm implementation
/// Guarantees optimal shortest path for graphs with non-negative edge weights
final class Dijkstra: PathfindingAlgorithmProtocol {
    
    /// Finds shortest path using Dijkstra's single-source shortest path algorithm
    ///
    /// - Parameters:
    ///   - graph: The weighted graph G = (V, E)
    ///   - source: Source vertex s ∈ V
    ///   - target: Target vertex t ∈ V
    /// - Returns: PathResult containing δ(s,t), the path, and exploration metadata
    static func findPath(in graph: Graph, from source: Int, to target: Int) -> PathResult {
        let n = graph.nodeCount
        
        // d[v] = current best known distance from source to v
        // Initially: d[s] = 0, d[v] = ∞ for all v ≠ s
        var distances = Array(repeating: Double.infinity, count: n)
        
        // π[v] = predecessor of v on shortest path (for path reconstruction)
        var previous = Array(repeating: -1, count: n)
        
        // S = set of vertices whose final shortest path weight is determined
        // Once v ∈ S, we have d[v] = δ(s, v) (optimal)
        var visited = Set<Int>()
        visited.reserveCapacity(n)
        
        var exploredEdges: [(from: Int, to: Int)] = []
        exploredEdges.reserveCapacity(n * 4)
        
        // Q = min-priority queue keyed by d[v] values
        // Invariant: Q contains vertices in V - S
        var pq = PriorityQueue<Int>()
        
        // Base case: distance from source to itself is 0
        distances[source] = 0
        pq.insert(source, priority: 0)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        // Main loop: extract vertex with minimum d[v] value
        // Greedy choice: the vertex with minimum d[v] has its shortest path finalized
        while let (currentDist, current) = pq.extractMin() {
            
            // Skip if already processed (handles duplicate entries in PQ)
            // This occurs because we insert duplicates rather than decrease-key
            if visited.contains(current) { continue }
            
            // Add to S: d[current] is now finalized as δ(s, current)
            visited.insert(current)
            
            // Early termination: target found with optimal distance
            // This is valid because no shorter path can exist (greedy property)
            if current == target {
                break
            }
            
            // RELAXATION STEP
            // For each edge (current, neighbor) ∈ E:
            // Check if path s → current → neighbor is better than current best
            for edge in graph.neighbors(of: current) {
                exploredEdges.append((from: current, to: edge.to))
                
                // New candidate distance: d[current] + w(current, neighbor)
                let newDist = currentDist + edge.weight
                
                // Relaxation: update if we found a shorter path
                // d[v] = min(d[v], d[u] + w(u,v))
                if newDist < distances[edge.to] {
                    distances[edge.to] = newDist
                    previous[edge.to] = current
                    
                    // Add to PQ (lazy deletion: may create duplicates)
                    // Alternative: decrease-key operation (more complex)
                    pq.insert(edge.to, priority: newDist)
                }
            }
        }
        
        let executionTime = CFAbsoluteTimeGetCurrent() - start
        
        // PATH RECONSTRUCTION
        // Follow predecessor chain: t → π[t] → π[π[t]] → ... → s
        // Then reverse to get s → ... → t
        
        // No path exists: target unreachable from source
        if distances[target] == .infinity {
            return PathResult(
                distance: .infinity,
                path: [],
                exploredNodes: visited,
                exploredEdges: exploredEdges,
                executionTime: executionTime
            )
        }
        
        // Build path by backtracking through predecessor array
        var path: [Int] = []
        var current = target
        while current != -1 {
            path.append(current)
            current = previous[current]
        }
        path.reverse()  // Reverse to get source → target order
        
        return PathResult(
            distance: distances[target],
            path: path,
            exploredNodes: visited,
            exploredEdges: exploredEdges,
            executionTime: executionTime
        )
    }
}
