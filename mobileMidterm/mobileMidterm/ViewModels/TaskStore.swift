//
//  TaskStore.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Central ObservableObject that owns all in-memory task and category data.
//  Views observe this store and mutate it through its methods.

import SwiftUI
internal import Combine

// MARK: - TaskStore

/// Shared state container for tasks and categories.
/// Injected into the view hierarchy via .environmentObject().
@MainActor
final class TaskStore: ObservableObject {

    // MARK: Published State

    @Published var tasks: [TaskItem] = []
    @Published var categories: [TaskCategory] = []

    // MARK: Initializer — seeds sample data so the app isn't empty on first launch

    init() {
        // Seed default categories
        let work     = TaskCategory(name: "Work",     colorHex: "007AFF")
        let school   = TaskCategory(name: "School",   colorHex: "FF9500")
        let personal = TaskCategory(name: "Personal", colorHex: "34C759")
        categories = [work, school, personal]

        // Seed a few sample tasks
        tasks = [
            TaskItem(
                title: "Finish SwiftUI project",
                description: "Complete the midterm task tracker app.",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                categoryID: school.id,
                estimatedMinutes: 120,
                status: .inProgress
            ),
            TaskItem(
                title: "Team standup prep",
                description: "Review sprint board before the morning standup.",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                categoryID: work.id,
                estimatedMinutes: 15,
                status: .notStarted
            ),
            TaskItem(
                title: "Grocery run",
                dueDate: Date(),
                categoryID: personal.id,
                estimatedMinutes: 45,
                status: .complete
            )
        ]
    }

    // MARK: - Task Operations
    
    /// This follows the CRUD application formula. The code to be able to create, read, update, and delete tasks lives here.

    /// Adds a new task to the list.
    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }

    /// Replaces an existing task identified by its UUID.
    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    /// Removes tasks at the given index set (used by List onDelete).
    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    /// Cycles a task's status: notStarted → inProgress → complete → notStarted.
    func cycleStatus(for task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        switch tasks[index].status {
        case .notStarted: tasks[index].status = .inProgress
        case .inProgress: tasks[index].status = .complete
        case .complete:   tasks[index].status = .notStarted
        }
    }

    // MARK: - Category Operations

    /// Adds a new category.
    func addCategory(_ category: TaskCategory) {
        categories.append(category)
    }

    /// Deletes categories and clears their association from existing tasks.
    func deleteCategories(at offsets: IndexSet) {
        let removedIDs = Set(offsets.map { categories[$0].id })
        categories.remove(atOffsets: offsets)
        // Orphan tasks that belonged to a deleted category
        for index in tasks.indices where tasks[index].categoryID.map({ removedIDs.contains($0) }) == true {
            tasks[index].categoryID = nil
        }
    }

    // MARK: - Helpers

    /// Returns the TaskCategory for a given ID, if it still exists.
    func category(for id: UUID?) -> TaskCategory? {
        guard let id else { return nil }
        return categories.first(where: { $0.id == id })
    }

    /// Filters tasks whose status matches the given value.
    func tasks(withStatus status: TaskStatus) -> [TaskItem] {
        tasks.filter { $0.status == status }
    }

    // MARK: - Extra Credit: Category Time Summary

    /// Returns a sorted array of CategorySummaryItem using Dictionary(grouping:by:) and reduce.
    func categoryTimeSummary() -> [CategorySummaryItem] {
        // Group tasks by category name using Dictionary(grouping:by:)
        let grouped = Dictionary(grouping: tasks) { task -> String in
            category(for: task.categoryID)?.name ?? "Uncategorized"
        }
        // Reduce each group to a total of estimatedMinutes
        let summary = grouped.map { (name, items) -> CategorySummaryItem in
            let total = items.reduce(0) { $0 + $1.estimatedMinutes }
            return CategorySummaryItem(categoryName: name, totalMinutes: total)
        }
        return summary.sorted { $0.categoryName < $1.categoryName }
    }
}

// MARK: - Category Summary Item

/// Value type returned by TaskStore.categoryTimeSummary() for use in ForEach.
struct CategorySummaryItem: Identifiable {
    let id = UUID()
    let categoryName: String
    let totalMinutes: Int
}
