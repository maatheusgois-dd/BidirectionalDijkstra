//
//  StatsHeaderView.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import SwiftUI

/// View displaying algorithm statistics
struct StatsHeaderView: View {
    let algorithm: PathfindingAlgorithm
    let animationState: AnimationState
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        HStack(spacing: 0) {
            algorithmLabel
            
            Divider()
                .frame(height: 40)
                .background(Color.gray.opacity(0.3))
            
            statsRow
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.13, green: 0.13, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var algorithmLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("ALGO")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
            Text(algorithm == .dijkstra ? "DIJKSTRA" : "BIDIR")
                .font(.system(size: isCompact ? 11 : 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: isCompact ? 60 : 80, alignment: .leading)
        .padding(.horizontal, 8)
    }
    
    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(label: "E", value: "\(animationState.exploredCount)", color: .cyan)
            
            Divider()
                .frame(height: 30)
                .background(Color.gray.opacity(0.2))
            
            statItem(label: "N", value: "\(animationState.exploredNodesCount)", color: .orange)
            
            Divider()
                .frame(height: 30)
                .background(Color.gray.opacity(0.2))
            
            statItem(
                label: "D",
                value: animationState.distance.map { String(format: "%.0f", $0) } ?? "-",
                color: .green
            )
            
            Divider()
                .frame(height: 30)
                .background(Color.gray.opacity(0.2))
            
            statItem(
                label: "μs",
                value: animationState.executionTime.map { String(format: "%.0f", $0 * 1_000_000) } ?? "-",
                color: .purple
            )
        }
    }
    
    private func statItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: isCompact ? 12 : 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.1), value: value)
        }
        .frame(maxWidth: .infinity)
    }
}
