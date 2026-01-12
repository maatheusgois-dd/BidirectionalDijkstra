//
//  BidirectionalDijkstra.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

// MARK: - Bidirectional Dijkstra's Algorithm
//
// ══════════════════════════════════════════════════════════════════════════════
// MATHEMATICAL FOUNDATION
// ══════════════════════════════════════════════════════════════════════════════
//
// Bidirectional search runs two simultaneous Dijkstra searches:
//   • Forward search:  from source s, computing d_f[v] = δ(s, v)
//   • Backward search: from target t, computing d_b[v] = δ(v, t)
//
// KEY INSIGHT:
//   Any s-t path must pass through some vertex m (meeting point).
//   The shortest path has length: δ(s, t) = min over all m { d_f[m] + d_b[m] }
//
// WHY IT'S FASTER:
//   Standard Dijkstra explores a "sphere" of radius r = δ(s, t) around s.
//   Area ∝ πr² in 2D graphs.
//
//   Bidirectional explores two "spheres" each of radius ≈ r/2:
//   Total area ∝ 2 × π(r/2)² = πr²/2
//
//   Theoretical speedup: ~2x fewer nodes explored in uniform graphs.
//   In practice: 2-4x speedup on road networks and large sparse graphs.
//
//          Standard Dijkstra:           Bidirectional Dijkstra:
//
//              ●●●●●●●                      ●●●           ●●●
//            ●●●●●●●●●●●                  ●●●●●●●       ●●●●●●●
//           ●●●●●●●●●●●●●                ●●●●s●●●●     ●●●●t●●●●
//          ●●●●●●s●●●●●●●t                ●●●●●●●   ↔   ●●●●●●●
//           ●●●●●●●●●●●●●                  ●●●●●         ●●●●●
//            ●●●●●●●●●●●                    ●●●           ●●●
//              ●●●●●●●
//
// ══════════════════════════════════════════════════════════════════════════════
// TERMINATION CONDITION
// ══════════════════════════════════════════════════════════════════════════════
//
// Let μ_f = minimum distance extracted from forward PQ (last settled distance)
// Let μ_b = minimum distance extracted from backward PQ
//
// THEOREM: We can terminate when μ_f + μ_b ≥ μ (best found path length)
//
// PROOF:
//   After termination, any unsettled vertex v has:
//     d_f[v] ≥ μ_f  (not yet extracted from forward PQ)
//     d_b[v] ≥ μ_b  (not yet extracted from backward PQ)
//
//   Any path through v has length ≥ d_f[v] + d_b[v] ≥ μ_f + μ_b ≥ μ
//   Therefore, no undiscovered path can be shorter than μ. ∎
//
// ══════════════════════════════════════════════════════════════════════════════
// MEETING POINT DETECTION
// ══════════════════════════════════════════════════════════════════════════════
//
// The searches "meet" when we find a vertex v such that:
//   • v has been reached by forward search:  d_f[v] < ∞
//   • v has been reached by backward search: d_b[v] < ∞
//
// IMPORTANT: The first meeting point is NOT necessarily on the shortest path!
//
// Example:     s ----1---- a ----1---- t
//               \                     /
//                \----10---- b ---10--
//
// Forward settles: s, then a      (μ_f = 1 after settling a)
// Backward settles: t, then a     (μ_b = 1 after settling a)
// They meet at a with total = 2, which IS optimal.
//
// But in other graphs, we must continue searching until μ_f + μ_b ≥ μ
// to guarantee we haven't missed a better path.
//
// ══════════════════════════════════════════════════════════════════════════════
// COMPLEXITY
// ══════════════════════════════════════════════════════════════════════════════
//
// Worst case: O((V + E) log V) — same as standard Dijkstra
// Average case on road networks: O(√V · log V) — much faster!
//
// Space: O(V) for two sets of distances, predecessors, and visited sets
//
// ══════════════════════════════════════════════════════════════════════════════

/// Bidirectional Dijkstra's algorithm implementation
/// Searches from both source and target simultaneously for improved performance
final class BidirectionalDijkstra: PathfindingAlgorithmProtocol {
    
    /// Finds shortest path using bidirectional search from both endpoints
    ///
    /// The algorithm maintains two search frontiers that expand toward each other:
    /// - Forward frontier: expands from source, computing δ(s, v)
    /// - Backward frontier: expands from target, computing δ(v, t)
    ///
    /// - Parameters:
    ///   - graph: The weighted graph G = (V, E)
    ///   - source: Source vertex s ∈ V
    ///   - target: Target vertex t ∈ V
    /// - Returns: PathResult with optimal path s → t
    static func findPath(in graph: Graph, from source: Int, to target: Int) -> PathResult {
        let n = graph.nodeCount
        
        // ═══════════════════════════════════════════════════════════════════════
        // FORWARD SEARCH STATE (from source s)
        // ═══════════════════════════════════════════════════════════════════════
        
        // d_f[v] = current best known distance from s to v
        var distForward = Array(repeating: Double.infinity, count: n)
        
        // π_f[v] = predecessor of v on shortest s → v path
        var prevForward = Array(repeating: -1, count: n)
        
        // S_f = vertices with finalized shortest distance from s
        var visitedForward = Set<Int>()
        visitedForward.reserveCapacity(n / 2)
        
        // Q_f = min-priority queue for forward search
        var pqForward = PriorityQueue<Int>()
        
        // ═══════════════════════════════════════════════════════════════════════
        // BACKWARD SEARCH STATE (from target t)
        // ═══════════════════════════════════════════════════════════════════════
        
        // d_b[v] = current best known distance from v to t
        // (computed by searching backward from t)
        var distBackward = Array(repeating: Double.infinity, count: n)
        
        // π_b[v] = successor of v on shortest v → t path
        var prevBackward = Array(repeating: -1, count: n)
        
        // S_b = vertices with finalized shortest distance to t
        var visitedBackward = Set<Int>()
        visitedBackward.reserveCapacity(n / 2)
        
        // Q_b = min-priority queue for backward search
        var pqBackward = PriorityQueue<Int>()
        
        var exploredEdges: [(from: Int, to: Int)] = []
        exploredEdges.reserveCapacity(n * 2)
        
        // ═══════════════════════════════════════════════════════════════════════
        // INITIALIZATION
        // ═══════════════════════════════════════════════════════════════════════
        
        // Base cases: d_f[s] = 0, d_b[t] = 0
        distForward[source] = 0
        distBackward[target] = 0
        pqForward.insert(source, priority: 0)
        pqBackward.insert(target, priority: 0)
        
        // μ = best known s-t path length found so far
        // m = meeting vertex on best known path
        var bestDistance = Double.infinity
        var meetingNode = -1
        
        // μ_f = minimum distance extracted from forward PQ (monotonically increasing)
        // μ_b = minimum distance extracted from backward PQ
        // Used for termination condition: μ_f + μ_b ≥ μ
        var muForward = 0.0
        var muBackward = 0.0
        
        let start = CFAbsoluteTimeGetCurrent()
        
        // ═══════════════════════════════════════════════════════════════════════
        // MAIN LOOP: Alternate between forward and backward expansion
        // ═══════════════════════════════════════════════════════════════════════
        
        while !pqForward.isEmpty || !pqBackward.isEmpty {
            
            // ─────────────────────────────────────────────────────────────────────
            // TERMINATION CHECK
            // If μ_f + μ_b ≥ μ, no undiscovered path can improve our best
            // ─────────────────────────────────────────────────────────────────────
            if muForward + muBackward >= bestDistance {
                break
            }
            
            // ─────────────────────────────────────────────────────────────────────
            // DIRECTION SELECTION
            // Expand the search with smaller frontier (load balancing)
            // This keeps both searches roughly synchronized
            // ─────────────────────────────────────────────────────────────────────
            let expandForward = !pqForward.isEmpty && (pqBackward.isEmpty || muForward <= muBackward)
            
            if expandForward {
                // ═══════════════════════════════════════════════════════════════
                // FORWARD EXPANSION
                // ═══════════════════════════════════════════════════════════════
                
                guard let (currentDist, current) = pqForward.extractMin() else { continue }
                
                // Skip duplicates (lazy deletion strategy)
                if visitedForward.contains(current) { continue }
                
                // Settle vertex: d_f[current] is now finalized
                visitedForward.insert(current)
                muForward = currentDist  // Update frontier distance
                
                // ─────────────────────────────────────────────────────────────────
                // MEETING CHECK: Did we reach a vertex settled by backward search?
                // Path length = d_f[current] + d_b[current]
                // ─────────────────────────────────────────────────────────────────
                if visitedBackward.contains(current) {
                    let totalDist = distForward[current] + distBackward[current]
                    if totalDist < bestDistance {
                        bestDistance = totalDist
                        meetingNode = current
                    }
                }
                
                // ─────────────────────────────────────────────────────────────────
                // RELAXATION: For each outgoing edge (current → neighbor)
                // ─────────────────────────────────────────────────────────────────
                for edge in graph.neighbors(of: current) {
                    exploredEdges.append((from: current, to: edge.to))
                    
                    // Candidate distance: d_f[current] + w(current, neighbor)
                    let newDist = currentDist + edge.weight
                    
                    // Relaxation step
                    if newDist < distForward[edge.to] {
                        distForward[edge.to] = newDist
                        prevForward[edge.to] = current
                        pqForward.insert(edge.to, priority: newDist)
                    }
                    
                    // ─────────────────────────────────────────────────────────────
                    // CROSS-FRONTIER CHECK
                    // If backward search has reached edge.to, we have a candidate path:
                    // s → ... → current → edge.to → ... → t
                    // Length = d_f[current] + w(current, edge.to) + d_b[edge.to]
                    //        = newDist + d_b[edge.to]
                    // ─────────────────────────────────────────────────────────────
                    let backDist = distBackward[edge.to]
                    if backDist < .infinity {
                        let totalDist = newDist + backDist
                        if totalDist < bestDistance {
                            bestDistance = totalDist
                            meetingNode = edge.to
                        }
                    }
                }
            } else {
                // ═══════════════════════════════════════════════════════════════
                // BACKWARD EXPANSION
                // Symmetric to forward, but searching from t toward s
                // ═══════════════════════════════════════════════════════════════
                
                guard let (currentDist, current) = pqBackward.extractMin() else { continue }
                
                if visitedBackward.contains(current) { continue }
                
                // Settle vertex: d_b[current] is now finalized
                visitedBackward.insert(current)
                muBackward = currentDist
                
                // Meeting check: forward search already settled this vertex?
                if visitedForward.contains(current) {
                    let totalDist = distForward[current] + distBackward[current]
                    if totalDist < bestDistance {
                        bestDistance = totalDist
                        meetingNode = current
                    }
                }
                
                // Relax edges (backward direction conceptually, but same edges in undirected graph)
                for edge in graph.neighbors(of: current) {
                    exploredEdges.append((from: current, to: edge.to))
                    
                    let newDist = currentDist + edge.weight
                    
                    if newDist < distBackward[edge.to] {
                        distBackward[edge.to] = newDist
                        prevBackward[edge.to] = current
                        pqBackward.insert(edge.to, priority: newDist)
                    }
                    
                    // Cross-frontier check: can we improve via forward search?
                    let fwdDist = distForward[edge.to]
                    if fwdDist < .infinity {
                        let totalDist = fwdDist + newDist
                        if totalDist < bestDistance {
                            bestDistance = totalDist
                            meetingNode = edge.to
                        }
                    }
                }
            }
        }
        
        let executionTime = CFAbsoluteTimeGetCurrent() - start
        
        // Total explored = union of both search frontiers
        let exploredNodes = visitedForward.union(visitedBackward)
        
        // ═══════════════════════════════════════════════════════════════════════
        // HANDLE NO PATH CASE
        // ═══════════════════════════════════════════════════════════════════════
        
        if meetingNode == -1 || bestDistance == .infinity {
            return PathResult(
                distance: .infinity,
                path: [],
                exploredNodes: exploredNodes,
                exploredEdges: exploredEdges,
                executionTime: executionTime
            )
        }
        
        // ═══════════════════════════════════════════════════════════════════════
        // PATH RECONSTRUCTION
        // Build complete path by joining:
        //   1. Forward path:  s → ... → meetingNode (via π_f)
        //   2. Backward path: meetingNode → ... → t (via π_b)
        // ═══════════════════════════════════════════════════════════════════════
        
        // Part 1: Trace back from meeting node to source using π_f
        var pathForward: [Int] = []
        var current = meetingNode
        while current != -1 {
            pathForward.append(current)
            current = prevForward[current]
        }
        pathForward.reverse()  // Now: s → ... → meetingNode
        
        // Part 2: Trace forward from meeting node to target using π_b
        // (π_b[v] points toward target, so we follow it forward)
        var pathBackward: [Int] = []
        current = prevBackward[meetingNode]  // Start after meeting node (avoid duplicate)
        while current != -1 {
            pathBackward.append(current)
            current = prevBackward[current]
        }
        // pathBackward is now: [node after meeting] → ... → t
        
        // Concatenate: s → ... → meetingNode → ... → t
        return PathResult(
            distance: bestDistance,
            path: pathForward + pathBackward,
            exploredNodes: exploredNodes,
            exploredEdges: exploredEdges,
            executionTime: executionTime
        )
    }
}
