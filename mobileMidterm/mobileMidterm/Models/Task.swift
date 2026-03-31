//
//  Task.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Defines the core TaskItem data model and TaskStatus enum.
//  Primary device: iPhone 16 Pro

import Foundation

// MARK: - Task Status

/// Represents the three possible states of a task's progress.
enum TaskStatus: String, CaseIterable, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case complete   = "Complete"

    /// SF Symbol name used to represent each status visually.
    var iconName: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "clock.fill"
        case .complete:   return "checkmark.circle.fill"
        }
    }
}

// MARK: - TaskItem Model

/// A single task entry in the tracker.
/// Named TaskItem to avoid collision with Swift's concurrency Task type.
struct TaskItem: Identifiable {
    let id: UUID           // Unique identifier — see developer.apple.com/documentation/foundation/uuid
    var title: String
    var description: String
    var dueDate: Date
    var categoryID: UUID?  // Optional — a task may be uncategorized
    var estimatedMinutes: Int
    var status: TaskStatus

    /// Convenience initializer with sensible defaults.
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        dueDate: Date = Date(),
        categoryID: UUID? = nil,
        estimatedMinutes: Int = 30,
        status: TaskStatus = .notStarted
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.categoryID = categoryID
        self.estimatedMinutes = estimatedMinutes
        self.status = status
    }

    /// Human-readable formatted estimated time (e.g. "1 hr 30 min").
    var formattedEstimate: String {
        let hours = estimatedMinutes / 60
        let mins  = estimatedMinutes % 60
        if hours > 0 && mins > 0 { return "\(hours) hr \(mins) min" }
        if hours > 0              { return "\(hours) hr" }
        return "\(mins) min"
    }
}
