//
//  JXBMapView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

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
    @Binding var currentLocation: CustomPointAnnotation?
    @Binding var destinationLocation: CustomPointAnnotation?

    func makeUIViewController(context: Context) -> MapViewController {
        let controller = MapViewController()
        controller.viewModel = viewModel
        return controller
    }

    func updateUIViewController(
        _ controller: MapViewController,
        context: Context
    ) {
        controller.viewModel = viewModel
        controller.updateRoute(from: currentLocation, to: destinationLocation)
    }
}

struct JXBMapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showDestinationSearch = false
    @State private var showDestinationDetails = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                MapView(
                    viewModel: viewModel,
                    currentLocation: $viewModel.selectedCurrentLocation,
                    destinationLocation: $viewModel.selectedDestinationLocation
                )
                .ignoresSafeArea()

                // Animated bottom component
                if viewModel.selectedDestinationLocation == nil {
                    VStack(alignment: .center, spacing: 16) {
                        HStack(alignment: .center) {
                            Text("Where do u wanna go?")
                                .font(
                                    Font.custom("Mulish", size: 20)
                                        .weight(.bold)
                                )
                                .fixedSize()

                            Spacer()

                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "magnifyingglass")
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                            .foregroundStyle(.white)
                            .background(.accent)
                            .cornerRadius(24)
                            .onTapGesture(
                                perform: { showDestinationSearch.toggle() }
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
                        height: geometry.safeAreaInsets.bottom + 100,
                        alignment: .topLeading
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: -1)
                    .glassEffect(
                        .regular,
                        in: .rect(topLeadingRadius: 24, topTrailingRadius: 24)
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
            }
        }
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showDestinationSearch.toggle() }) {
                    Image(systemName: "info.circle")
                }
            }
        }
        .onChange(of: viewModel.userLocation) { oldLocation, userLocation in
            guard let userLocation = userLocation,
                viewModel.selectedCurrentLocation == nil
            else { return }

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
        .onChange(of: viewModel.selectedDestinationLocation) { _, destination in
            withAnimation(.easeInOut(duration: 0.4)) {
                showDestinationDetails = destination != nil
            }
        }
        .fullScreenCover(isPresented: $showDestinationSearch) {
            DestinationView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showDestinationDetails) {
            if let destination = viewModel.selectedDestinationLocation {
                DestinationSheetContentView(
                    destination: destination,
                    onSearchTapped: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedDestinationLocation = nil
                        }
                        showDestinationSearch = true
                    },
                    onDoneTapped: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedDestinationLocation = nil
                        }
                        showDestinationSearch = false
                    }
                )
                .presentationDetents([.height(95), .medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationBackgroundInteraction(.enabled)
                .background(.regularMaterial)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.selectedDestinationLocation)
    }
}
