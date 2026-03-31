//
//  CategoryTimeSummaryView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Extra Credit: Time totals per category, minimal plain list layout.
//  Logic lives in TaskStore.categoryTimeSummary() using Dictionary + reduce.

import SwiftUI

// MARK: - Category Time Summary View

struct CategoryTimeSummaryView: View {

    @EnvironmentObject private var store: TaskStore
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            summaryContent
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
            Text("Summary")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.title2)
                .opacity(0)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: Summary Content

    @ViewBuilder
    private var summaryContent: some View {
        if store.tasks.isEmpty {
            Spacer()
            Text("No tasks to summarize")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        } else {
            List {
                ForEach(store.categoryTimeSummary()) { entry in
                    HStack {
                        Text(entry.categoryName)
                            .font(.body)
                        Spacer()
                        Text(formatMinutes(entry.totalMinutes))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparatorTint(Color(UIColor.separator))
                }

                // Grand total row
                HStack {
                    Text("Total")
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(formatMinutes(store.tasks.reduce(0) { $0 + $1.estimatedMinutes }))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .listRowInsets(EdgeInsets())
                .listRowSeparatorTint(Color(UIColor.separator))
            }
            .listStyle(.plain)
        }
    }

    // MARK: Helpers

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins  = minutes % 60
        if hours > 0 && mins > 0 { return "\(hours)h \(mins)m" }
        if hours > 0              { return "\(hours)h" }
        return "\(mins)m"
    }
}

// MARK: - Preview

#Preview {
    CategoryTimeSummaryView(onMenu: {})
        .environmentObject(TaskStore())
}
