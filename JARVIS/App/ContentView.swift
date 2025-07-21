//
//  ContentView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

import SwiftUI

struct ContentView: View {
    enum Tabs: String, Equatable, Hashable, Identifiable {
        case home = "Home"
        case feed = "Feed"
        case discover = "Discover"
        case profile = "Profile"

        var id: Tabs { self }
    }

    @State private var selectedTab: Tabs = .home

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house", value: .home) {
                    HomeView()
                }
                Tab("Feed", systemImage: "square.grid.2x2", value: .feed) {
                    FeedView()
                }
                Tab(
                    "Discover",
                    systemImage: "location.circle",
                    value: .discover
                ) {
                    DiscoverView()
                }
                Tab(
                    "Profile",
                    systemImage: "person.crop.circle.fill",
                    value: .profile
                ) {
                    ProfileView()
                }
            }
            .navigationTitle(selectedTab.rawValue)
        }
    }
}

#Preview {
    ContentView()
}
