//
//  ControlPanelView.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import SwiftUI

/// View containing algorithm controls
struct ControlPanelView: View {
    @Binding var selectedAlgorithm: PathfindingAlgorithm
    @Binding var animationSpeed: AnimationSpeed
    let isAnimating: Bool
    let onAlgorithmChange: (PathfindingAlgorithm) -> Void
    let onNewMap: () -> Void
    let onRandomPoints: () -> Void
    let onRunStop: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 12) {
            algorithmPicker
            speedPicker
            actionButtons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
    }
    
    private var algorithmPicker: some View {
        Picker("Algorithm", selection: $selectedAlgorithm) {
            Text("DIJKSTRA").tag(PathfindingAlgorithm.dijkstra)
            Text("BIDIR").tag(PathfindingAlgorithm.bidirectional)
        }
        .pickerStyle(.segmented)
        .disabled(isAnimating)
        .onChange(of: selectedAlgorithm) { _, newAlgorithm in
            onAlgorithmChange(newAlgorithm)
        }
    }
    
    private var speedPicker: some View {
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
    }
    
    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: onNewMap) {
                HStack(spacing: 4) {
                    Image(systemName: "map")
                    Text("Map")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isAnimating)
            
            Button(action: onRandomPoints) {
                HStack(spacing: 4) {
                    Image(systemName: "shuffle")
                    Text("Rand")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isAnimating)
            
            Button(action: onRunStop) {
                HStack(spacing: 4) {
                    Image(systemName: isAnimating ? "stop.fill" : "play.fill")
                    Text(isAnimating ? "Stop" : "Run")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isAnimating ? .red : .blue)
        }
        .font(.system(size: 13, weight: .medium))
    }
}
