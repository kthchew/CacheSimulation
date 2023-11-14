//
//  CacheSetupForm.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/12/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct CacheSetupForm: View {
    @State private var addressInput = [UInt32]()
    @State private var showingFilePicker = false
    
    @ObservedObject var matrix: CacheMatrix
    
    var body: some View {
        Form {
            Section {
                Stepper(value: $matrix.cacheSizePowerLow, in: matrix.lineSizePower...matrix.cacheSizePowerHigh) {
                    Text("Cache Size (Low)")
                    Text("2^\(matrix.cacheSizePowerLow) (\(pow(2, matrix.cacheSizePowerLow).formatted())) bytes")
                }
                
                Stepper(value: $matrix.cacheSizePowerHigh, in: matrix.cacheSizePowerLow...31) {
                    Text("Cache Size (High)")
                    Text("2^\(matrix.cacheSizePowerHigh) (\(pow(2, matrix.cacheSizePowerHigh).formatted())) bytes")
                }
                
                Stepper(value: $matrix.lineSizePower, in: 1...matrix.cacheSizePowerLow) {
                    Text("Line Size")
                    Text("2^\(matrix.lineSizePower) (\(pow(2, matrix.lineSizePower).formatted())) bytes")
                }
            } header: {
                Text("Sizes")
            }
            
            Section {
                Toggle(isOn: $matrix.directMappedEnabled) {
                    Text("Direct Mapped")
                }
                Toggle(isOn: $matrix.fullyAssociativeEnabled) {
                    Text("Fully Associative")
                }
                Toggle(isOn: $matrix.setAssociativeEnabled) {
                    Text("Set Associative")
                }
            } header: {
                Text("Cache Organization")
            }
            
            if matrix.cacheTypes.contains(.setAssociative) {
                Section {
                    Stepper(value: $matrix.setSizePowerLow, in: 1...max(4, matrix.setSizePowerHigh)) {
                        Text("Lines Per Set (Low)")
                        Text("2^\(matrix.setSizePowerLow) (\(pow(2, matrix.setSizePowerLow).formatted())) lines")
                    }
                    
                    Stepper(value: $matrix.setSizePowerHigh, in: matrix.setSizePowerLow...max(4, matrix.cacheSizePowerLow - matrix.lineSizePower)) {
                        Text("Lines Per Set (High)")
                        Text("2^\(matrix.setSizePowerHigh) (\(pow(2, matrix.setSizePowerHigh).formatted())) lines")
                    }
                } header: {
                    Text("Set Sizes (Set Associative)")
                }
            }
            
            if matrix.cacheTypes.contains(.setAssociative) || matrix.cacheTypes.contains(.fullyAssociative) {
                Section {
                    Toggle(isOn: $matrix.fifoEnabled) {
                        Text("First In First Out (FIFO)")
                    }
                    Toggle(isOn: $matrix.lruEnabled) {
                        Text("Least Recently Used (LRU)")
                    }
                } header: {
                    Text("Collision Resolution")
                }
            }
            
            Section {
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
                
                HStack {
                    Button {
                        matrix.runSimulations(with: addressInput)
                    } label: {
                        Text("Test")
                    }
                    .disabled(
                        ((matrix.cacheTypes.contains(.setAssociative) && (matrix.cacheSizePowerLow < matrix.setSizePowerHigh + matrix.lineSizePower)))
                        || addressInput.isEmpty
                        || matrix.isRunning
                    )
                    if matrix.isRunning {
                        ProgressView()
                        .controlSize(.small)
                        .padding(2)
                    }
                }
            }
            
        }
        .formStyle(.grouped)
    }
}

#Preview {
    @StateObject var matrix = CacheMatrix()
    return CacheSetupForm(matrix: matrix)
}
