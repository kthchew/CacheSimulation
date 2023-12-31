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
    @State private var selectedFilename = ""
    @State private var selectedFileIcon: NSImage?
    @State private var isLoadingFile = false
    
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
                VStack(alignment: .leading) {
                    Button {
                        showingFilePicker = true
                    } label: {
                        Text("Choose File")
                    }
                    .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.plainText, UTType(filenameExtension: "trace")!], allowsMultipleSelection: false) { result in
                        switch result {
                        case .success(let files):
                            Task {
                                await loadFiles(files)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    .disabled(isLoadingFile)
                    
                    HStack {
                        if let icon = selectedFileIcon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text(selectedFilename)
                                .font(.caption)
                                .padding(.trailing, 4)
                        }
                        
                        if isLoadingFile {
                            ProgressView()
                                .controlSize(.mini)
                        }
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
    
    nonisolated func loadFiles(_ files: [URL]) async {
        files.forEach { file in
            let accessed = file.startAccessingSecurityScopedResource()
            if !accessed { return }
            
            do {
                Task { @MainActor in
                    isLoadingFile = true
                    selectedFilename = file.lastPathComponent
                    selectedFileIcon = NSWorkspace.shared.icon(forFile: file.relativePath)
                }
                
                let addresses = try String(contentsOf: file, encoding: .utf8)
                    .components(separatedBy: .whitespacesAndNewlines)
                    .filter { word in
                        word.starts(with: "0x")
                    }
                    .compactMap {
                        UInt32($0.dropFirst(2), radix: 16)
                    }
                
                Task { @MainActor in
                    addressInput = addresses
                    isLoadingFile = false
                }
            } catch {
                Task { @MainActor in
                    isLoadingFile = false
                    selectedFilename = ""
                    selectedFileIcon = nil
                }
                return
            }
            
            file.stopAccessingSecurityScopedResource()
        }
    }
}

#Preview {
    @StateObject var matrix = CacheMatrix()
    return CacheSetupForm(matrix: matrix)
}
