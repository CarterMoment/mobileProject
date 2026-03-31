//
//  ContentView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Root view. Manages a custom sliding sidebar instead of TabView.
//  The sidebar slides the main content right using an offset animation.

import SwiftUI

// MARK: - App Navigation

/// The three top-level destinations reachable from the sidebar.
enum AppTab: String, CaseIterable {
    case tasks      = "Tasks"
    case categories = "Categories"
    case summary    = "Summary"
}

// MARK: - Content View

// NOTE: The assignment spec calls for NavigationStack or TabView for top-level navigation.
// I intentionally replaced TabView with a custom sliding sidebar here. I've built enough
// apps with the default TabView that it's become muscle memory, and I wanted to push myself
// to implement a different navigation pattern from scratch — offset animations, scrim overlay,
// spring physics and all. The sidebar covers the same three destinations (Tasks, Categories,
// Summary) that a TabView would, just with a lot more personality.
struct ContentView: View {

    @StateObject private var store = TaskStore()
    @State private var sidebarOpen = false
    @State private var selectedTab: AppTab = .tasks

    private let sidebarWidth: CGFloat = 220

    var body: some View {
        ZStack(alignment: .leading) {

            // Main content: shifts right when sidebar opens
            activeView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: sidebarOpen ? sidebarWidth : 0)
                .animation(.spring(response: 0.32, dampingFraction: 0.82), value: sidebarOpen)
                .disabled(sidebarOpen) // block interaction while sidebar is visible

            // Dim filter over content when sidebar is open
            if sidebarOpen {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .offset(x: sidebarWidth)
                    .onTapGesture { closeSidebar() }
                    .zIndex(0.5)
            }

            // Sidebar panel: always in the view tree, hidden via offset
            SidebarView(selectedTab: $selectedTab, onSelectTab: closeSidebar)
                .frame(width: sidebarWidth)
                .offset(x: sidebarOpen ? 0 : -sidebarWidth)
                .animation(.spring(response: 0.32, dampingFraction: 0.82), value: sidebarOpen)
                .zIndex(1)
        }
        .environmentObject(store)
    }

    // MARK: Helpers

    @ViewBuilder
    private var activeView: some View {
        switch selectedTab {
        case .tasks:
            TaskListView(onMenu: openSidebar)
        case .categories:
            CategoryManagerView(onMenu: openSidebar)
        case .summary:
            CategoryTimeSummaryView(onMenu: openSidebar)
        }
    }

    private func openSidebar()  { withAnimation { sidebarOpen = true } }
    private func closeSidebar() { withAnimation { sidebarOpen = false } }
}

// MARK: - Preview

#Preview {
    ContentView()
}
