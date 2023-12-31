//
//  SimulationResult.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation
import CoreTransferable

struct SimulationResult: Hashable, Identifiable, Transferable {
    let id = UUID()
    
    let type: CacheType
    let cacheSizePower: Int
    let lineSizePower: Int
    let setSizePower: Int
    let collisionStrategy: CollisionHandlingStrategy
    
    let hits: Int
    let totalRequests: Int
    var misses: Int {
        totalRequests - hits
    }
    var hitRate: Double {
        Double(hits) / Double(totalRequests)
    }
    
    func tabDelimitedString() -> String {
        let first = "\(type == .setAssociative ? "\(1 << setSizePower)-way " : "")\(type.rawValue)\(type != .directMapped ? " (\(collisionStrategy.rawValue))" : "")"
        let second = (1 << cacheSizePower).formatted()
        let third = (1 << lineSizePower).formatted()
        let fourth = hitRate.formatted()
        return "\(first)\t\(second)\t\(third)\t\(fourth)"
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .utf8TabSeparatedText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .tabSeparatedText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .delimitedText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .utf8PlainText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .plainText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .text) { item in
            return Data(item.tabDelimitedString().utf8)
        }
    }
}
