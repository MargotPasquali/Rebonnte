//
//  MedicineTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Testing
import Foundation
import FirebaseFirestore
import FirebaseFirestore
@testable import MediStock

@Suite("Medicine")
struct MedicineTests {
    
    @Test
    func testMedicineInitialization() {
        let id = "testMedicineID1"
        let name = "Aspirin"
        let stock = 50
        let aisle = "A1"
        
        let medicine = Medicine(id: id, name: name, stock: stock, aisle: aisle)
        
        #expect(medicine.id == id)
        #expect(medicine.name == name)
        #expect(medicine.stock == stock)
        #expect(medicine.aisle == aisle)
    }
    
    @Test
    func testMedicineEquatable() {
        let medicine1 = Medicine(id: "testMedicineID1", name: "Aspirin", stock: 50, aisle: "A1")
        let medicine2 = Medicine(id: "testMedicineID1", name: "Aspirin", stock: 50, aisle: "A1")
        let medicine3 = Medicine(id: "testMedicineID2", name: "Paracetamol", stock: 30, aisle: "B2")
        
        #expect(medicine1 == medicine2)
        #expect(medicine1 != medicine3)
    }
    
}
