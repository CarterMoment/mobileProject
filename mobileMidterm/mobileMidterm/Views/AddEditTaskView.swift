//
//  AddEditTaskView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Minimal sheet form for creating or editing a task.
//  No NavigationStack, no Section headers — custom header with Cancel/Save.

import SwiftUI

// MARK: - Add / Edit Task View

struct AddEditTaskView: View {

    @EnvironmentObject private var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    let existingTask: TaskItem?

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCategoryID: UUID? = nil
    @State private var estimatedMinutes: Int = 30
    @State private var status: TaskStatus = .notStarted
    @State private var showingValidationAlert = false

    private let minuteRange: ClosedRange<Double> = 5...480

    init(existingTask: TaskItem? = nil) {
        self.existingTask = existingTask
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    fieldRow("Title") {
                        TextField("What needs to be done?", text: $title)
                            .font(.body)
                    }

                    fieldRow("Description") {
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Optional")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 1)
                            }
                            TextEditor(text: $description)
                                .frame(minHeight: 64)
                                .scrollDisabled(true)
                        }
                        .font(.body)
                    }

                    fieldRow("Due Date") {
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .labelsHidden()
                    }

                    fieldRow("Estimated Time") {
                        HStack {
                            Slider(
                                value: Binding(
                                    get: { Double(estimatedMinutes) },
                                    set: { estimatedMinutes = Int($0) }
                                ),
                                in: minuteRange,
                                step: 5
                            )
                            Text(TaskItem(title: "", estimatedMinutes: estimatedMinutes).formattedEstimate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 72, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }

                    fieldRow("Category") {
                        Picker("", selection: $selectedCategoryID) {
                            Text("None").tag(UUID?.none)
                            ForEach(store.categories) { cat in
                                Text(cat.name).tag(Optional(cat.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    // Status picker only shown in edit mode
                    if existingTask != nil {
                        fieldRow("Status") {
                            Picker("", selection: $status) {
                                ForEach(TaskStatus.allCases, id: \.self) { s in
                                    Text(s.rawValue).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .alert("Title Required", isPresented: $showingValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a title for your task.")
        }
        .onAppear(perform: populateIfEditing)
    }

    // MARK: Sheet Header

    private var sheetHeader: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundStyle(.secondary)
            Spacer()
            Text(existingTask == nil ? "New Task" : "Edit Task")
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Button("Save") { saveTask() }
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: Field Row

    /// Uniform field layout: small uppercase label, content, bottom divider.
    private func fieldRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(0.5)
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: Data Helpers

    private func populateIfEditing() {
        guard let task = existingTask else { return }
        title = task.title
        description = task.description
        dueDate = task.dueDate
        selectedCategoryID = task.categoryID
        estimatedMinutes = task.estimatedMinutes
        status = task.status
    }

    private func saveTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showingValidationAlert = true
            return
        }

        if let existing = existingTask {
            store.updateTask(TaskItem(
                id: existing.id,
                title: trimmed,
                description: description,
                dueDate: dueDate,
                categoryID: selectedCategoryID,
                estimatedMinutes: estimatedMinutes,
                status: status
            ))
        } else {
            store.addTask(TaskItem(
                title: trimmed,
                description: description,
                dueDate: dueDate,
                categoryID: selectedCategoryID,
                estimatedMinutes: estimatedMinutes,
                status: .notStarted
            ))
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview("Add Task") {
    AddEditTaskView()
        .environmentObject(TaskStore())
}

#Preview("Edit Task") {
    AddEditTaskView(existingTask: TaskItem(
        title: "Existing Task",
        description: "Edit me",
        estimatedMinutes: 60,
        status: .inProgress
    ))
    .environmentObject(TaskStore())
}
