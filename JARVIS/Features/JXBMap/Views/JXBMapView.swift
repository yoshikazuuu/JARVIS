//
//  JXBMapView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var selectedCurrentLocation: CustomPointAnnotation?
    @Binding var selectedDestinationLocation: CustomPointAnnotation?

    func makeUIViewController(context: Context) -> MapViewController {
        let controller = MapViewController()
        controller.viewModel = viewModel
        return controller
    }

    func updateUIViewController(
        _ uiViewController: MapViewController,
        context: Context
    ) {
        uiViewController.viewModel = viewModel
        uiViewController.updateRoute(
            from: selectedCurrentLocation,
            to: selectedDestinationLocation
        )
    }
}

struct JXBMapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var isDestinationSelectionOpen = false
    @State private var text: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                MapView(
                    viewModel: viewModel,
                    selectedCurrentLocation: $viewModel.selectedCurrentLocation,
                    selectedDestinationLocation: $viewModel.selectedDestinationLocation
                )
                .ignoresSafeArea()

                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center) {
                        if let destination = viewModel.selectedDestinationLocation {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(destination.title ?? "Unknown")
                                    .font(.mulish(20, .bold))
                                    .foregroundStyle(Color.text)

                                Text(destination.properties?.location ?? "Unknown")
                                    .font(.mulish(14, .semibold))
                                    .foregroundStyle(Color.textSecondary)
                            }
                        } else {
                            Text("Where do u wanna go?")
                                .font(
                                    Font.custom("Mulish", size: 20)
                                        .weight(.bold)
                                )
                                .fixedSize()
                        }

                        Spacer()

                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "magnifyingglass")
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                        .foregroundStyle(.white)
                        .background(.accent)
                        .cornerRadius(24)
                        .onTapGesture(
                            perform: { isDestinationSelectionOpen.toggle() }
                        )
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .padding(.bottom, 8)
                .frame(
                    width: geometry.size.width,
                    height: geometry.safeAreaInsets.bottom + 80,
                    alignment: .topLeading
                )
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: -1)
                .glassEffect(
                    .regular,
                    in: .rect(topLeadingRadius: 24, topTrailingRadius: 24)
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isDestinationSelectionOpen.toggle() }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .ignoresSafeArea()
            .fullScreenCover(
                isPresented: $isDestinationSelectionOpen,
                content: {
                    DestinationView()
                        .environmentObject(viewModel)
                }
            )
            .onChange(of: viewModel.userLocation) { oldLocation, userLocation in
                // Only pre-fill if a location is found and a current location hasn't been selected yet.
                guard let userLocation = userLocation, viewModel.selectedCurrentLocation == nil else { return }

                var closestLocation: CustomPointAnnotation?
                var minDistance: CLLocationDistance = .greatestFiniteMagnitude

                for location in viewModel.locations {
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
        }
    }
}
