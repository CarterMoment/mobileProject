//
//  CategoryManagerView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Minimal category manager. No section headers, plain list style.
//  Inline text field at the top to add categories; swipe to delete.

import SwiftUI

// MARK: - Category Manager View

struct CategoryManagerView: View {

    @EnvironmentObject private var store: TaskStore
    let onMenu: () -> Void

    @State private var newCategoryName: String = ""
    @State private var showingDeleteAlert = false
    @State private var pendingDeleteOffsets: IndexSet? = nil

    var body: some View {
        VStack(spacing: 0) {
            header

            // Add-category input row
            HStack {
                TextField("New category name", text: $newCategoryName)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit(addCategory)
                    .font(.body)
                Button(action: addCategory) {
                    Image(systemName: "plus")
                        .foregroundStyle(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty
                                         ? Color.secondary : Color.primary)
                }
                .buttonStyle(.plain)
                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Divider()

            // Category list
            if store.categories.isEmpty {
                Spacer()
                Text("No categories yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(store.categories) { category in
                        categoryRow(category)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparatorTint(Color(UIColor.separator))
                    }
                    .onDelete { offsets in
                        pendingDeleteOffsets = offsets
                        showingDeleteAlert = true
                    }
                }
                .listStyle(.plain)
            }
        }
        .alert("Delete Category?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let offsets = pendingDeleteOffsets {
                    store.deleteCategories(at: offsets)
                }
                pendingDeleteOffsets = nil
            }
            Button("Cancel", role: .cancel) { pendingDeleteOffsets = nil }
        } message: {
            Text("Tasks in this category will become uncategorized.")
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button(action: onMenu) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
            }
            Spacer()
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            // Balance the hamburger button visually
            Image(systemName: "line.3.horizontal")
                .font(.title2)
                .opacity(0)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: Category Row

    private func categoryRow(_ category: TaskCategory) -> some View {
        let count = store.tasks.filter { $0.categoryID == category.id }.count
        return HStack {
            Text(category.name)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 20)
            }
        }
    }

    // MARK: Helpers

    private func addCategory() {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addCategory(TaskCategory(name: trimmed))
        newCategoryName = ""
    }
}

// MARK: - Preview

#Preview {
    CategoryManagerView(onMenu: {})
        .environmentObject(TaskStore())
}
