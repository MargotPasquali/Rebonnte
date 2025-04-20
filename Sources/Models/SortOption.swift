//
//  SortOption.swift
//  MediStock
//
//  Created by Margot Pasquali on 25/03/2025.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case name
    case stock

    var id: String { self.rawValue }
}
