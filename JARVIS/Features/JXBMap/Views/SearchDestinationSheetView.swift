//
//  SearchDestinationSheetView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

import SwiftUI
import MapKit

struct SearchDestinationSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MapViewModel
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white)

                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("Search your destination")
                            .foregroundStyle(.white.opacity(0.7))
                    )
                    .foregroundStyle(.white)
                }
                .padding()
                .clipShape(.rect(cornerRadius: 24))
                .glassEffect(.clear)

                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.white)
                .padding()
                .glassEffect(.clear)
            }
            .padding()
            .background {
                Color.accent
            }

            List(
                viewModel.locations.filter {
                    searchText.isEmpty
                        || $0.title?.localizedCaseInsensitiveContains(
                            searchText
                        )
                        ?? false
                },
                id: \.self
            ) { location in
                Button(action: {
                    viewModel.selectedDestinationLocation = location
                    dismiss()
                }) {
                    let booth = Booth(
                        name: location.properties?.name
                            ?? "Unknown",
                        location: location.properties?.location
                            ?? "Unknown",
                        boothType: BoothType(
                            rawValue: location.properties?
                                .booth_type ?? ""
                        ) ?? .booth
                    )
                    BoothRowView(booth: booth, isInSearch: true)
                }
            }
            .listStyle(.plain)
        }
    }
}
