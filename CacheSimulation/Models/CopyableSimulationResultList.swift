//
//  CopyableSimulationResultList.swift
//  CacheSimulation
//
//  Created by Kenneth Chew on 11/14/23.
//

import Foundation
import CoreTransferable

/// A list of simulation results that are copyable as a singular item.
///
/// This is used as a workaround for an array of SimulationResults only pasting a singular row into Microsoft Excel.
struct CopyableSimulationResultList: Hashable, Transferable {
    var results = [SimulationResult]()
    
    func tabDelimitedString() -> String {
        results
            .map {
                $0.tabDelimitedString()
            }
            .joined(separator: "\n")
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .utf8TabSeparatedText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .tabSeparatedText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .delimitedText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .utf8PlainText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .plainText) { item in
            return Data(item.tabDelimitedString().utf8)
        }
        DataRepresentation(exportedContentType: .text) { item in
            return Data(item.tabDelimitedString().utf8)
        }
    }
}
