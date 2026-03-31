//
//  SidebarView.swift
//  mobileMidterm
//
//  Created by Carter Frank on 3/29/26.
//
//  Colored sliding sidebar panel that replaces TabView for navigation.
//  Uses large text nav items with an indicator line on the active item.

import SwiftUI

// MARK: - Sidebar

struct SidebarView: View {

    @Binding var selectedTab: AppTab
    let onSelectTab: () -> Void  // Called after selecting to close the sidebar

    // Deep indigo — the signature color of the sidebar
    private let bg = Color(red: 0.08, green: 0.05, blue: 0.22)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // App name at the top
            Text("Midterm")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.top, 64)
                .padding(.leading, 28)
                .padding(.bottom, 48)

            // Navigation items
            ForEach(AppTab.allCases, id: \.self) { tab in
                navItem(tab)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(bg.ignoresSafeArea())
    }

    // MARK: Nav Item

    private func navItem(_ tab: AppTab) -> some View {
        let isActive = selectedTab == tab
        return Button {
            selectedTab = tab
            onSelectTab()
        } label: {
            HStack(spacing: 0) {
                // Active indicator bar on the left edge
                Rectangle()
                    .frame(width: 3)
                    .foregroundStyle(isActive ? Color.white : Color.clear)
                    .padding(.vertical, 6)

                Text(tab.rawValue)
                    .font(.title3)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundStyle(isActive ? .white : .white.opacity(0.4))
                    .padding(.leading, 24)
                    .padding(.vertical, 14)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SidebarView(selectedTab: .constant(.tasks), onSelectTab: {})
}
