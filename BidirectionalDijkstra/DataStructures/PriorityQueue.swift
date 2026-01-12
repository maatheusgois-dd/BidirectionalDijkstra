//
//  PriorityQueue.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import Foundation

struct PriorityQueue<T> {
    private var heap: [(priority: Double, element: T)]
    
    init() {
        heap = []
    }
    
    var isEmpty: Bool { heap.isEmpty }
    var count: Int { heap.count }
    
    mutating func insert(_ element: T, priority: Double) {
        heap.append((priority, element))
        siftUp(heap.count - 1)
    }
    
    mutating func extractMin() -> (priority: Double, element: T)? {
        guard !heap.isEmpty else { return nil }
        if heap.count == 1 { return heap.removeLast() }
        
        let min = heap[0]
        heap[0] = heap.removeLast()
        siftDown(0)
        return min
    }
    
    private mutating func siftUp(_ index: Int) {
        var i = index
        while i > 0 {
            let parent = (i - 1) / 2
            if heap[i].priority < heap[parent].priority {
                heap.swapAt(i, parent)
                i = parent
            } else {
                break
            }
        }
    }
    
    private mutating func siftDown(_ index: Int) {
        var i = index
        let count = heap.count
        
        while true {
            let left = 2 * i + 1
            let right = 2 * i + 2
            var smallest = i
            
            if left < count && heap[left].priority < heap[smallest].priority {
                smallest = left
            }
            if right < count && heap[right].priority < heap[smallest].priority {
                smallest = right
            }
            
            if smallest != i {
                heap.swapAt(i, smallest)
                i = smallest
            } else {
                break
            }
        }
    }
}

