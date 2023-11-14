//
//  SimulationResult.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation

struct SimulationResult: Hashable, Identifiable {
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
}
