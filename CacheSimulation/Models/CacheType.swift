//
//  CacheType.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/12/23.
//

import Foundation

enum CacheType: String, Hashable, CaseIterable, Comparable {
    case directMapped = "Direct Mapped"
    case fullyAssociative = "Fully Associative"
    case setAssociative = "Set Associative"
    
    static func <(a: CacheType, b: CacheType) -> Bool {
        return a.rawValue < b.rawValue
    }
}
