//
//  SearchCurrentLocationSheetView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

import MapKit
import SwiftUI

struct SearchCurrentLocationSheetView: View {
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
                        prompt: Text("Search your current location")
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
                    viewModel.selectedCurrentLocation = location
                    dismiss()
                }) {
                    Text(location.title ?? "Unknown")
                }
            }
            .listStyle(.plain)
        }
    }
}
