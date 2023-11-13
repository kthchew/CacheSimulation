//
//  Cache.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation

@MainActor class Cache: ObservableObject {
    @Published var cacheSizePower = 10 {
        didSet {
            clearCachedProperties()
        }
    }
    @Published var lineSizePower = 6 {
        didSet {
            clearCachedProperties()
        }
    }
    @Published var cacheType = CacheType.directMapped {
        didSet {
            clearCachedProperties()
        }
    }
    @Published var setSizePowerInput = 2 {
        didSet {
            clearCachedProperties()
        }
    }
    @Published var collisionStrategy = CollisionHandlingStrategy.leastRecentlyUsed
    
    private var cache = [[Int]]()
    
    var numLinesPower: Int {
        cacheSizePower - lineSizePower
    }
    
    var numLines: Int {
        1 << numLinesPower
    }
    
    var setSizePower: Int {
        switch cacheType {
        case .directMapped:
            0
        case .fullyAssociative:
            numLinesPower
        case .setAssociative:
            setSizePowerInput
        }
    }
    
    private var _setSize: Int? // caching because this calculation is a bottleneck for large inputs
    var setSize: Int {
        if let _setSize = _setSize {
            return _setSize
        } else {
            _setSize = 1 << setSizePower
            return _setSize!
        }
    }
    
    var numSetsPower: Int {
        numLinesPower - setSizePower
    }
    
    var numSets: Int {
        1 << numSetsPower
    }
    
    private var _tagSizePower: Int? // caching because this calculation is a bottleneck for large inputs
    var tagSizePower: Int {
        if let _tagSizePower = _tagSizePower {
            return _tagSizePower
        } else {
            _tagSizePower = 32 - numSetsPower - lineSizePower
            return _tagSizePower!
        }
    }
    
    private func clearCachedProperties() {
        _setSize = nil
        _tagSizePower = nil
    }
    
    func initializeCache() {
        cache = Array(repeating: [-1, -1], count: numLines)
    }
    
    func checkCache(address: UInt32, counter: Int) -> Bool {
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
