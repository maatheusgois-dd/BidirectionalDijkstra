# Bidirectional Dijkstra Visualizer

A SwiftUI macOS app that visualizes and compares Dijkstra's algorithm with Bidirectional Dijkstra's algorithm for shortest path finding.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features

- **Visual comparison** of standard Dijkstra vs Bidirectional Dijkstra
- **Animated pathfinding** with configurable speed (slow, normal, fast)
- **Interactive controls** to generate new maps and randomize start/end points
- **Real-time statistics** showing nodes explored, execution time, and path distance
- **Side-by-side comparison mode** to see both algorithms running simultaneously

## Algorithms

### Standard Dijkstra
Classic single-source shortest path algorithm that explores outward from the source until reaching the target.

### Bidirectional Dijkstra
Runs two simultaneous searches:
- **Forward search**: from source → target
- **Backward search**: from target → source

The searches meet in the middle, typically exploring ~50% fewer nodes than standard Dijkstra.

```
Standard Dijkstra:           Bidirectional Dijkstra:

    ●●●●●●●                      ●●●           ●●●
  ●●●●●●●●●●●                  ●●●●●●●       ●●●●●●●
 ●●●●●●●●●●●●●                ●●●●s●●●●     ●●●●t●●●●
●●●●●●s●●●●●●●t                ●●●●●●●   ↔   ●●●●●●●
 ●●●●●●●●●●●●●                  ●●●●●         ●●●●●
  ●●●●●●●●●●●                    ●●●           ●●●
    ●●●●●●●
```

## Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/MaatheusGois/BidirectionalDijkstra.git
```

2. Open `BidirectionalDijkstra.xcodeproj` in Xcode

3. Build and run (⌘R)

## Usage

### Single Mode
- Select an algorithm from the dropdown
- Click **Run** to start the animated visualization
- Use **New Map** to generate a different graph
- Use **Random Points** to change source/target positions

### Comparison Mode
- Watch both algorithms run side-by-side
- Compare nodes explored, execution time, and path length
- See the efficiency gain of bidirectional search in real-time

## Project Structure

```
BidirectionalDijkstra/
├── Algorithms/
│   ├── BidirectionalDijkstra.swift   # Bidirectional implementation
│   ├── Dijkstra.swift                 # Standard Dijkstra
│   └── PathfindingAlgorithm.swift     # Protocol & enum
├── DataStructures/
│   └── PriorityQueue.swift            # Min-heap priority queue
├── Models/
│   ├── Graph.swift                    # Adjacency list graph
│   ├── GraphNode.swift                # Node with position
│   ├── Edge.swift                     # Weighted edge
│   └── PathResult.swift               # Algorithm result
├── ViewModels/
│   └── AnimationState.swift           # Animation state management
├── Views/
│   ├── ContentView.swift              # Root view
│   ├── PathfindingView.swift          # Single algorithm view
│   ├── ComparisonView.swift           # Side-by-side comparison
│   ├── MapVisualizationView.swift     # Graph rendering
│   ├── ControlPanelView.swift         # UI controls
│   └── StatsHeaderView.swift          # Statistics display
└── Services/
    └── MapGenerator.swift             # Graph generation
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Matheus Gois** - [@MaatheusGois](https://github.com/MaatheusGois)

