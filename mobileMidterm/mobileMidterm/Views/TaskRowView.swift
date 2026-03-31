//
//  TaskRowView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Minimal task row. Status is a colored dot; tapping it cycles the status.
//  No icons — typography and color carry the visual weight.

import SwiftUI

// MARK: - Task Row

struct TaskRowView: View {

    let task: TaskItem
    let categoryName: String?
    let onStatusTap: () -> Void

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    var body: some View {
        HStack(alignment: .center, spacing: 16) {

            // Left: title + meta line
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.status == .complete)
                    .foregroundStyle(task.status == .complete ? Color.secondary : Color.primary)

                // Meta: date · category · time — all in one subtle line
                Text(metaLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right: status dot — tap to cycle
            Button(action: onStatusTap) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: Helpers

    /// Single meta line combining date, category, and estimate.
    private var metaLine: String {
        var parts: [String] = [Self.dateFormatter.string(from: task.dueDate)]
        if let name = categoryName { parts.append(name) }
        parts.append(task.formattedEstimate)
        return parts.joined(separator: "  ·  ")
    }

    private var statusColor: Color {
        switch task.status {
        case .notStarted: return Color(UIColor.systemGray3)
        case .inProgress: return .orange
        case .complete:   return .green
        }
    }
}

// MARK: - Preview

#Preview {
    let sample = TaskItem(
        title: "Finish SwiftUI project",
        dueDate: Date(),
        estimatedMinutes: 90,
        status: .inProgress
    )
    TaskRowView(task: sample, categoryName: "School", onStatusTap: {})
}
