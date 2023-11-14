//
//  CacheMatrix.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation
import SwiftUI

class CacheMatrix: ObservableObject {
    @Published var cacheSizePowerLow = 10
    @Published var cacheSizePowerHigh = 12
    
    @Published var lineSizePower = 6
    
    @Published var cacheTypes: Set<CacheType> = [CacheType.directMapped]
    var directMappedEnabled: Bool {
        get {
            cacheTypes.contains(.directMapped)
        }
        set {
            withAnimation {
                if newValue {
                    cacheTypes.insert(.directMapped)
                } else {
                    cacheTypes.remove(.directMapped)
                }
            }
        }
    }
    var fullyAssociativeEnabled: Bool {
        get {
            cacheTypes.contains(.fullyAssociative)
        }
        set {
            withAnimation {
                if newValue {
                    cacheTypes.insert(.fullyAssociative)
                } else {
                    cacheTypes.remove(.fullyAssociative)
                }
            }
        }
    }
    var setAssociativeEnabled: Bool {
        get {
            cacheTypes.contains(.setAssociative)
        }
        set {
            withAnimation {
                if newValue {
                    cacheTypes.insert(.setAssociative)
                } else {
                    cacheTypes.remove(.setAssociative)
                }
            }
        }
    }
    
    @Published var setSizePowerLow = 1
    @Published var setSizePowerHigh = 3
    
    @Published var collisionStrategies: Set<CollisionHandlingStrategy> = [CollisionHandlingStrategy.leastRecentlyUsed]
    var fifoEnabled: Bool {
        get {
            collisionStrategies.contains(.firstInFirstOut)
        }
        set {
            withAnimation {
                if newValue {
                    collisionStrategies.insert(.firstInFirstOut)
                } else {
                    collisionStrategies.remove(.firstInFirstOut)
                }
            }
        }
    }
    var lruEnabled: Bool {
        get {
            collisionStrategies.contains(.leastRecentlyUsed)
        }
        set {
            withAnimation {
                if newValue {
                    collisionStrategies.insert(.leastRecentlyUsed)
                } else {
                    collisionStrategies.remove(.leastRecentlyUsed)
                }
            }
        }
    }
    
    @Published var results = [SimulationResult]()
    
    private func runSimulation(withCacheType cacheType: CacheType, collisionStrategy: CollisionHandlingStrategy, cacheSizePower: Int, lineSizePower: Int, setSizePower: Int, addresses: [UInt32], results: inout [SimulationResult]) {
        var hits = 0
        var counter = 0
        var cache = Cache(cacheType: cacheType, collisionStrategy: collisionStrategy, cacheSizePower: cacheSizePower, lineSizePower: lineSizePower, setSizePower: setSizePower)
        for address in addresses {
            let found = cache.checkCache(address: address, counter: counter)
            if found {
                hits += 1
            }
            counter += 1
        }
        
        let result = SimulationResult(type: cacheType, cacheSizePower: cacheSizePower, lineSizePower: lineSizePower, setSizePower: setSizePower, collisionStrategy: collisionStrategy, hits: hits, totalRequests: counter)
        results.append(result)
    }
    
    func runSimulations(with addresses: [UInt32]) {
        for cacheSizePower in cacheSizePowerLow...cacheSizePowerHigh {
            for collisionStrategy in collisionStrategies {
                for cacheType in cacheTypes {
                    if (cacheType == .setAssociative) {
                        for setSizePower in setSizePowerLow...setSizePowerHigh {
                            runSimulation(withCacheType: cacheType, collisionStrategy: collisionStrategy, cacheSizePower: cacheSizePower, lineSizePower: lineSizePower, setSizePower: setSizePower, addresses: addresses, results: &results)
                        }
                    } else {
                        runSimulation(withCacheType: cacheType, collisionStrategy: collisionStrategy, cacheSizePower: cacheSizePower, lineSizePower: lineSizePower, setSizePower: 0, addresses: addresses, results: &results)
                    }
                }
            }
        }
    }
}
