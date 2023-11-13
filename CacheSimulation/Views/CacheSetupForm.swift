//
//  CacheSetupForm.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/12/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct CacheSetupForm: View {
    @State private var first = 0
    @State private var second = 0
    @State private var result = 0.0
    @State private var addressInput = [UInt32]()
    @State private var showingFilePicker = false
    @StateObject var cache = Cache()
    
    var body: some View {
        Form {
            Stepper(value: $cache.cacheSizePower, in: cache.lineSizePower...31) {
                Text("Cache Size")
                Text("2^\(cache.cacheSizePower) (\(pow(2, cache.cacheSizePower).formatted())) bytes")
            }
            
            Stepper(value: $cache.lineSizePower, in: 1...cache.cacheSizePower) {
                Text("Line Size")
                Text("2^\(cache.lineSizePower) (\(pow(2, cache.lineSizePower).formatted())) bytes")
            }
            
            Picker("Cache Type", selection: $cache.cacheType.animation()) {
                Text("Direct Mapped").tag(CacheType.directMapped)
                Text("Fully Associative").tag(CacheType.fullyAssociative)
                Text("Set Associative").tag(CacheType.setAssociative)
            }
            
            if cache.cacheType == .setAssociative {
                Stepper(value: $cache.setSizePowerInput, in: 1...max(4, cache.cacheSizePower)) {
                    Text("Lines Per Set")
                    Text("2^\(cache.setSizePowerInput) (\(pow(2, cache.setSizePowerInput).formatted())) lines")
                }
                .transition(.opacity)
            }
            
            if cache.cacheType != .directMapped {
                Picker("Collision Handling Strategy", selection: $cache.collisionStrategy) {
                    Text("First In First Out (FIFO)").tag(CollisionHandlingStrategy.firstInFirstOut)
                    Text("Least Recently Used (LRU)").tag(CollisionHandlingStrategy.leastRecentlyUsed)
                }
                .transition(.opacity)
            }
            
//            TextEditor(text: $addressInput)
            
            Button {
                showingFilePicker = true
            } label: {
                Text("Choose File")
            }
            .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.plainText, UTType(filenameExtension: "trace")!], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let files):
                    files.forEach { file in
                        let accessed = file.startAccessingSecurityScopedResource()
                        if !accessed { return }
                        
                        do {
                            addressInput = try String(contentsOf: file, encoding: .utf8)
                                .components(separatedBy: .whitespacesAndNewlines)
                                .filter { word in
                                    word.starts(with: "0x")
                                }
                                .compactMap {
                                    UInt32($0.dropFirst(2), radix: 16)
                                }
                        } catch {
                            return
                        }
                        
                        file.stopAccessingSecurityScopedResource()
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
            Button {
                (first, second) = testCache(addresses: addressInput)
            } label: {
                Text("Test")
            }
            
            Text("\(first) \(second)")

        }
        .formStyle(.grouped)
    }
    
    func testCache(addresses: [UInt32]) -> (Int, Int) {
        cache.initializeCache()
        var hits = 0
        var counter = 0
        
        for address in addresses {
            let found = cache.checkCache(address: address, counter: counter)
            if (found) {
                hits += 1
            }
            counter += 1
        }
        return (hits, counter)
//        return Double(hits) / Double(counter)
    }
}

#Preview {
    CacheSetupForm()
}
