//
//  HistoryEntryTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Testing
import Foundation
import FirebaseFirestoreSwift
@testable import MediStock

@Suite("HistoryEntry")
struct HistoryEntryTests {
    
    @Test
    func testHistoryEntryInitialization() {
        // Given
        let id = "historyEntryID1"
        let medicineId = "medicineID1"
        let fullName = "John Doe"
        let action = "Added"
        let details = "Added medicine"
        let timestamp = Date(timeIntervalSince1970: 1633046400)
        
        // When
        let historyEntry = HistoryEntry(
            id: id,
            medicineId: medicineId,
            fullName: fullName,
            action: action,
            details: details,
            timestamp: timestamp
        )
        
        // Then
        #expect(historyEntry.id == id)
        #expect(historyEntry.medicineId == medicineId)
        #expect(historyEntry.fullName == fullName)
        #expect(historyEntry.action == action)
        #expect(historyEntry.details == details)
        #expect(historyEntry.timestamp == timestamp)
    }
    
    @Test
    func testHistoryEntryInitializationWithDefaultTimestamp() {
        // Given
        let id = "historyEntryID1"
        let medicineId = "medicineID1"
        let fullName = "Joh Doe"
        let action = "Added"
        let details = "Added medicine"
        let before = Date()
        
        // When
        let historyEntry = HistoryEntry(
            id: id,
            medicineId: medicineId,
            fullName: fullName,
            action: action,
            details: details
        )
        let after = Date()
        
        // Then
        #expect(historyEntry.id == id)
        #expect(historyEntry.medicineId == medicineId)
        #expect(historyEntry.fullName == fullName)
        #expect(historyEntry.action == action)
        #expect(historyEntry.details == details)
        #expect(historyEntry.timestamp >= before)
        #expect(historyEntry.timestamp <= after)
    }
}
