//
//  ResultTable.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import SwiftUI

struct ResultTable: View {
    @State private var sortOrder = [KeyPathComparator(\SimulationResult.type)]
    
    @ObservedObject var matrix: CacheMatrix
    @Binding var selected: Set<SimulationResult.ID>
    
    var body: some View {
        Table(matrix.results, selection: $selected, sortOrder: $sortOrder) {
            TableColumn("Cache Type", value: \.type) { result in
                Text("\(result.type == .setAssociative ? "\(1 << result.setSizePower)-way " : "")\(result.type.rawValue) \(result.type != .directMapped ? "(\(result.collisionStrategy.rawValue))" : "")")
            }
            TableColumn("Cache Size (bytes)", value: \.cacheSizePower) { result in
                Text("\((1 << result.cacheSizePower).formatted())")
            }
            TableColumn("Line Size (bytes)", value: \.lineSizePower) { result in
                Text("\((1 << result.lineSizePower).formatted())")
            }
            TableColumn("Hit Rate", value: \.hitRate) { result in
                Text("\(result.hitRate.formatted())")
            }
        }
        .onChange(of: sortOrder) {
            matrix.results.sort(using: $0)
        }
    }
}

#Preview {
    ResultTable(matrix: CacheMatrix(), selected: .constant([]))
}
