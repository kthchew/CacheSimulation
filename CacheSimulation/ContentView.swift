//
//  ContentView.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/12/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var matrix = CacheMatrix()
    
    var body: some View {
        NavigationSplitView {
            CacheSetupForm(matrix: matrix)
        } detail: {
            ResultTable(matrix: matrix)
        }
    }
}

#Preview {
    ContentView()
}
