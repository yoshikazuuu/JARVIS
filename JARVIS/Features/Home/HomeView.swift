//
//  Home.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        GeometryReader { geometry in
            NavigationLink {
                JXBMapView()
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome! You’re in JXB JCC")
                                .font(.mulish(14, .semibold))
                                .kerning(0.1)
                                .foregroundColor(.white.opacity(0.7))

                            HStack(alignment: .center, spacing: 8) {
                                Text("Explore booths")
                                    .font(.mulish(20, .bold))
                                    .kerning(0.1)
                                    .foregroundStyle(.white)

                                Image(systemName: "arrow.right")
                                    .foregroundStyle(.white)
                            }
                            .padding(0)
                        }
                        .padding(0)

                        Spacer()

                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "figure.walk")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                        }
                        .padding(10)
                        .background(.white.opacity(0.3))
                        .cornerRadius(8)
                    }
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
                .frame(width: geometry.size.width, alignment: .leading)
                .background(
                    ZStack(content: {
                        Color.accent
                        HStack {
                            Spacer()
                            Image("path")
                                .resizable()
                                .scaledToFit()
                        }
                    })
                )
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
            }
        }
        .padding(16)
    }
}

#Preview {
    HomeView()
}
