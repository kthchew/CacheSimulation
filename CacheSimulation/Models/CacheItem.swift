//
//  CacheItem.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/14/23.
//

import Foundation

struct CacheItem: Hashable {
    let tag: Int
    var timeLastUsed: Int
}
