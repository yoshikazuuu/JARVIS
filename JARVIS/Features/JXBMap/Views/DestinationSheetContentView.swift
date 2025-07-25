//
//  DestinationSheetContentView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 25/07/25.
//

import MapKit
import SwiftUI

struct DestinationSheetContentView: View {
    let destination: CustomPointAnnotation
    let onSearchTapped: () -> Void // Add this closure property

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(8)

            HStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.text.opacity(0.6))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.title ?? "Unknown Destination")
                        .font(.mulish(18, .bold))
                    Text(
                        destination.properties?.location
                            ?? "Location not available"
                    )
                    .font(.mulish(14, .regular))
                    .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        onSearchTapped() // Call the closure
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.accent)
                            .clipShape(Circle())
                    }

                    Button(action: {

                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.accent)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle().stroke(.accent, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(width: 250, height: 350)
                                    .overlay(
                                        Text("Bundle Placeholder").font(
                                            .mulish(16)
                                        )
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 350)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sustainable Beauty")
                            .font(.mulish(18, .bold))
                        Text("Local skincare from Indonesia")
                            .font(.mulish(14, .semibold))
                        Text(
                            "Blending natural ingredients with science-backed formulations, Avoskin creates high-quality products that care for both your skin and the environment."
                        )
                        .font(.mulish(15))
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    Button(action: {

                    }) {
                        Text("SEE ALL CATALOGUE")
                            .font(.mulish(16, .bold))
                            .foregroundStyle(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(.accent)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
    }
}
