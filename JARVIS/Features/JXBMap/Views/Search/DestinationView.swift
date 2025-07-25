//
//  DestinationView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct DestinationView: View {
    @EnvironmentObject var viewModel: MapViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isSearchCurrentLocationOpen = false
    @State private var isSearchDestinationOpen = false
    @State private var suggestedBooths: [CustomPointAnnotation] = []

    private var locationPickerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Text("Where do u wanna go?")
                    .font(.mulish(18, .bold))
                    .foregroundStyle(.text)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundStyle(.text)
                }
            }

            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Image(systemName: "arrowtriangle.down.circle.fill")
                        .foregroundStyle(
                            Color(red: 0.26, green: 0.52, blue: 0.96)
                        )

                    ForEach(0..<5) { _ in
                        Circle().frame(width: 2, height: 2)
                    }

                    Image(systemName: "location.fill")
                        .foregroundStyle(
                            Color(red: 0.91, green: 0.37, blue: 0.37)
                        )
                }

                VStack(alignment: .leading) {
                    Button {
                        isSearchCurrentLocationOpen.toggle()
                    } label: {
                        VStack(
                            alignment: .leading
                        ) {
                            if let currentLocation = viewModel
                                .selectedCurrentLocation
                            {
                                VStack(
                                    alignment: .leading,
                                    spacing: 0
                                ) {
                                    Text(currentLocation.title ?? "Unknown")
                                        .font(.mulish(14, .semibold))
                                    Text(
                                        currentLocation.properties?.location
                                            ?? "Unknown"
                                    )
                                    .font(.mulish(13))
                                    .foregroundStyle(.textSecondary)
                                }
                            } else {
                                Text("Select your current location")
                                    .font(.mulish(14, .semibold))
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 30)

                    Divider()

                    Button {
                        isSearchDestinationOpen.toggle()
                    } label: {
                        HStack {
                            if let destinationLocation = viewModel
                                .selectedDestinationLocation
                            {
                                VStack(
                                    alignment: .leading,
                                    spacing: 0
                                ) {
                                    Text(
                                        destinationLocation.title
                                            ?? "Unknown"
                                    )
                                    .font(.mulish(14, .semibold))
                                    .foregroundStyle(.text)
                                    Text(
                                        destinationLocation.properties?.location
                                            ?? "Unknown"
                                    )
                                    .font(.mulish(13))
                                    .foregroundStyle(.textSecondary)
                                }

                            } else {
                                Text("Pick your destination!")
                                    .font(.mulish(14, .semibold))
                                    .foregroundStyle(.textSecondary)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 30)
                }
            }
            .padding(12)
            .foregroundStyle(.text)
            .background {
                Color(red: 0.97, green: 0.97, blue: 0.97)
            }
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.netural300, lineWidth: 1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background {
            LinearGradient(
                colors: [.white, .accentColor.opacity(0.15)],
                startPoint: UnitPoint(x: 0.5, y: 0.3),
                endPoint: .bottom
            )
        }
        .overlay {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(0.9), .clear,
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.6
                    )
                    .frame(height: 1)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 24,
                            style: .continuous
                        )
                    )
                }
            }
        }
        .clipShape(
            .rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24)
        )
        .shadow(color: .black.opacity(0.12), radius: 1.5, x: 0, y: 2)
    }

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Suggestion for you")
                    .font(.mulish(12))
                    .foregroundStyle(.textSecondary.opacity(0.7))

                Spacer()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(suggestedBooths) { annotation in
                        Button(action: {
                            viewModel.selectedDestinationLocation = annotation

                            if let userLocation = viewModel.userLocation {
                                let potentialStartLocations = viewModel.locations.filter { $0.title != annotation.title }
                                var closestLocation: CustomPointAnnotation?
                                var minDistance: CLLocationDistance = .greatestFiniteMagnitude

                                for location in potentialStartLocations {
                                    let pointLocation = CLLocation(
                                        latitude: location.coordinate.latitude,
                                        longitude: location.coordinate.longitude
                                    )
                                    let distance = userLocation.distance(from: pointLocation)
                                    if distance < minDistance {
                                        minDistance = distance
                                        closestLocation = location
                                    }
                                }

                                viewModel.selectedCurrentLocation = closestLocation
                            }
                        }) {
                            let booth = Booth(
                                name: annotation.properties?.name
                                    ?? "Unknown",
                                location: annotation.properties?.location
                                    ?? "Unknown",
                                boothType: BoothType(
                                    rawValue: annotation.properties?
                                        .booth_type ?? ""
                                ) ?? .booth
                            )
                            BoothRowView(booth: booth)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .foregroundStyle(.text)
        .background {
            Color.white
        }
        .clipShape(.rect(cornerRadius: 4))
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            VStack(alignment: .center, spacing: 20) {
                locationPickerSection
                suggestionSection
            }
            .padding(.bottom, 0)
            .background {
                Color.surface
            }
        }
        .onAppear(perform: {
            suggestedBooths = Array(
                viewModel.boothLocations.shuffled().prefix(6)
            )
        })
        .onChange(
            of: viewModel.selectedCurrentLocation,
            {
                checkAndDismiss()
            }
        )
        .onChange(
            of: viewModel.selectedDestinationLocation,
            {
                checkAndDismiss()
            }
        )
        .sheet(isPresented: $isSearchCurrentLocationOpen) {
            SearchCurrentLocationSheetView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $isSearchDestinationOpen) {
            SearchDestinationSheetView()
                .environmentObject(viewModel)
        }
    }

    private func checkAndDismiss() {
        if viewModel.selectedCurrentLocation != nil,
           viewModel.selectedDestinationLocation != nil
        {
            dismiss()
        }
    }
}
