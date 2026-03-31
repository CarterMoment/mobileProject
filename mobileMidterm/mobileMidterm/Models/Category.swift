//
//  Category.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Defines the Category model that tasks can be assigned to.

import Foundation

// MARK: - Category Model

/// A user-defined category for grouping tasks (e.g. Work, School, Personal).
struct TaskCategory: Identifiable {
    let id: UUID
    var name: String
    var colorHex: String  // Stored as a hex string for easy display

    init(id: UUID = UUID(), name: String, colorHex: String = "007AFF") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}
