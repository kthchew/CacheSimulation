//
//  Cache.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation

struct Cache: Hashable {
    init(cacheType: CacheType, collisionStrategy: CollisionHandlingStrategy, cacheSizePower: Int, lineSizePower: Int, setSizePower: Int) {
        self.cacheSizePower = cacheSizePower
        self.lineSizePower = lineSizePower
        self.cacheType = cacheType
        self.collisionStrategy = collisionStrategy
        
        self.numLinesPower = cacheSizePower - lineSizePower
        self.numLines = 1 << numLinesPower
        
        switch cacheType {
        case .directMapped:
            self.setSizePower = 0
        case .fullyAssociative:
            self.setSizePower = numLinesPower
        case .setAssociative:
            self.setSizePower = setSizePower
        }
        
        self.setSize = 1 << self.setSizePower
        
        self.numSetsPower = numLinesPower - self.setSizePower
        self.numSets = 1 << numSetsPower
        
        self.tagSizePower = 32 - numSetsPower - lineSizePower
        
        self.cache = Array(repeating: [-1, -1], count: numLines)
    }
    
    let cacheSizePower: Int
    let lineSizePower: Int
    let setSizePower: Int
    let cacheType: CacheType
    let collisionStrategy: CollisionHandlingStrategy
    
    let numLinesPower: Int
    let numLines: Int
    
    let setSize: Int
    
    let numSetsPower: Int
    let numSets: Int
    
    let tagSizePower: Int
    
    private var cache = [[Int]]()
    
    mutating func resetCache() {
        self.cache = Array(repeating: [-1, -1], count: numLines)
    }
    
    mutating func checkCache(address: UInt32, counter: Int) -> Bool {
        let tag = Int(address >> (32 - tagSizePower)) // leftmost tagSize bits
        let set = Int(((address << (tagSizePower)) >> (tagSizePower + lineSizePower)))
        
        if (cacheType == .directMapped) {
            if (cache[set][0] == tag) {
                if (collisionStrategy == .leastRecentlyUsed) {
                    cache[set][1] = counter
                }
                return true
            } else {
                cache[set][0] = tag
                cache[set][1] = counter
                return false
            }
        }
        
        let setIndexStart = set * setSize
        let setIndexEnd = setIndexStart + setSize
        
        var emptyIndex = -1
        var smallestCounter = Int.max
        var smallestCounterIndex = -1
        
        for index in setIndexStart..<setIndexEnd {
            if (cache[index][0] == tag) { // found
                if (collisionStrategy == .leastRecentlyUsed) {
                    cache[index][1] = counter
                }
                return true
            } else if (cache[index][0] == -1 && emptyIndex == -1) { // find empty spot to put item
                emptyIndex = index
            } else if (cache[index][1] < smallestCounter) { // find oldest item to replace later
                smallestCounter = cache[index][1]
                smallestCounterIndex = index
            }
        }
        
        if (emptyIndex != -1) {
            cache[emptyIndex][0] = tag
            cache[emptyIndex][1] = counter
        } else {
            cache[smallestCounterIndex][0] = tag
            cache[smallestCounterIndex][1] = counter
        }
        return false
    }
}
