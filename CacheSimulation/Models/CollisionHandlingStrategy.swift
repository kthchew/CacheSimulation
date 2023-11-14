//
//  CollisionHandlingStrategy.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/13/23.
//

import Foundation

enum CollisionHandlingStrategy: String, Hashable, CaseIterable {
    case firstInFirstOut = "FIFO"
    case leastRecentlyUsed = "LRU"
}
