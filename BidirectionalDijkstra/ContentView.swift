//
//  ContentView.swift
//  Copyright © 2026 MaatheusGois. All rights reserved.
//

import SwiftUI

enum ViewMode: String, CaseIterable {
    case single = "Single"
    case comparison = "Compare"
}

struct ContentView: View {
    @State private var viewMode: ViewMode = .comparison
    
    var body: some View {
        VStack(spacing: 0) {
            // View mode picker
            Picker("Mode", selection: $viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 0.1, green: 0.1, blue: 0.12))
            
            // Content
            switch viewMode {
            case .single:
                PathfindingView()
            case .comparison:
                ComparisonView()
            }
        }
    }
}

#Preview {
    ContentView()
}
