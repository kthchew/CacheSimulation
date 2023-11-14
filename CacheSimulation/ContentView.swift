//
//  ContentView.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/12/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selected = Set<SimulationResult.ID>()
    @StateObject var matrix = CacheMatrix()
    
    var body: some View {
        NavigationSplitView {
            CacheSetupForm(matrix: matrix)
        } detail: {
            ResultTable(matrix: matrix, selected: $selected)
        }
        .copyable([CopyableSimulationResultList(results: matrix.results.filter { selected.contains($0.id) })])
    }
}

#Preview {
    ContentView()
}
