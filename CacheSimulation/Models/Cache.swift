//
//  Cache.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation
import OSLog

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
        
        self.cache = Array(repeating: nil, count: numLines)
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
    
    private var cache = [CacheItem?]()
    
    mutating func resetCache() {
        self.cache = Array(repeating: nil, count: numLines)
    }
    
    /// Checks whether the given address is stored in the cache, and adds or updates it if necessary.
    /// - Parameters:
    ///   - address: A memory address to check.
    ///   - time: A number representing the current time that is monotonically increasing.
    /// - Returns: A boolean describing whether the item was in the cache or not.
    mutating func checkCache(address: UInt32, time: Int) -> Bool {
        let tag = Int(address >> (32 - tagSizePower)) // leftmost tagSize bits
        let set = Int(((address << (tagSizePower)) >> (tagSizePower + lineSizePower)))
        
        if cacheType == .directMapped {
            if var item = cache[set], item.tag == tag {
                if collisionStrategy == .leastRecentlyUsed {
                    item.timeLastUsed = time
                }
                return true
            } else {
                cache[set] = CacheItem(tag: tag, timeLastUsed: time)
                return false
            }
        }
        
        let setIndexStart = set * setSize
        let setIndexEnd = setIndexStart + setSize
        
        var emptyIndex: Int?
        var earliestTime = Int.max
        var earliestTimeIndex: Int?
        
        for index in setIndexStart..<setIndexEnd {
            guard var item = cache[index] else {
                if emptyIndex == nil {
                    emptyIndex = index
                }
                continue
            }
            
            if item.tag == tag { // found
                if collisionStrategy == .leastRecentlyUsed {
                    item.timeLastUsed = time
                }
                return true
            } else if item.timeLastUsed < earliestTime { // find oldest item to replace later
                earliestTime = item.timeLastUsed
                earliestTimeIndex = index
            }
        }
        
        if let emptyIndex = emptyIndex {
            cache[emptyIndex] = CacheItem(tag: tag, timeLastUsed: time)
        } else if let earliestTimeIndex = earliestTimeIndex {
            cache[earliestTimeIndex] = CacheItem(tag: tag, timeLastUsed: time)
        } else {
            Logger().error("No valid indices for item in cache. This should never happen.")
        }
        return false
    }
}
