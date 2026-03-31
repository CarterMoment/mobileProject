//
//  TaskListView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Task list with a minimal custom header and underline filter tabs.
//  Plain List style — no inset grouped chrome, no section headers.

import SwiftUI

// MARK: - Task List View

struct TaskListView: View {

    @EnvironmentObject private var store: TaskStore
    let onMenu: () -> Void

    @State private var selectedFilter: TaskStatus? = nil
    @State private var taskToEdit: TaskItem? = nil
    @State private var showingAddTask = false

    private var filteredTasks: [TaskItem] {
        guard let filter = selectedFilter else { return store.tasks }
        return store.tasks.filter { $0.status == filter }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            filterBar
            Divider()
            taskList
        }
        .sheet(isPresented: $showingAddTask) { AddEditTaskView() }
        .sheet(item: $taskToEdit) { AddEditTaskView(existingTask: $0) }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button(action: onMenu) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
            }
            Spacer()
            Text("Tasks")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Button { showingAddTask = true } label: {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: Filter Bar

    /// Text tabs with an underline indicator — no pill chips.
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                filterTab(nil, "All")
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    filterTab(status, status.rawValue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }

    private func filterTab(_ status: TaskStatus?, _ label: String) -> some View {
        let active = selectedFilter == status
        return Button {
            selectedFilter = (selectedFilter == status && status != nil) ? nil : status
        } label: {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(active ? .semibold : .regular)
                    .foregroundStyle(active ? Color.primary : Color.secondary)
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundStyle(active ? Color.primary : Color.clear)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: Task List

    private var taskList: some View {
        Group {
            if filteredTasks.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(filteredTasks) { task in
                        TaskRowView(
                            task: task,
                            categoryName: store.category(for: task.categoryID)?.name,
                            onStatusTap: { store.cycleStatus(for: task) }
                        )
                        .listRowInsets(EdgeInsets())  // remove default List padding
                        .listRowSeparatorTint(Color(UIColor.separator))
                        .contentShape(Rectangle())
                        .onTapGesture { taskToEdit = task }
                    }
                    .onDelete(perform: deleteFromFiltered)
                }
                .listStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text(selectedFilter == nil ? "No tasks" : "No \(selectedFilter!.rawValue.lowercased()) tasks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if selectedFilter == nil {
                Button("Add one") { showingAddTask = true }
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Helpers

    private func deleteFromFiltered(at offsets: IndexSet) {
        let ids = offsets.map { filteredTasks[$0].id }
        let storeOffsets = IndexSet(store.tasks.indices.filter { ids.contains(store.tasks[$0].id) })
        store.deleteTasks(at: storeOffsets)
    }
}

// MARK: - Preview

#Preview {
    TaskListView(onMenu: {})
        .environmentObject(TaskStore())
}
