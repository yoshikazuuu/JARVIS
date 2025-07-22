//
//  JXBMapView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

import SwiftUI

struct JXBMapView: View {
    @State private var isOpen = true
    @State private var text: String = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                MapView()
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center) {
                        Text("Where do u wanna go?")
                            .font(
                                Font.custom("Mulish", size: 20)
                                    .weight(.bold)
                            )
                            .foregroundColor(.white)
                            .fixedSize()
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "magnifyingglass")
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(.white)
                        .cornerRadius(24)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .padding(.bottom, 8)
                .frame(
                    width: geometry.size.width,
                    height: geometry.safeAreaInsets.bottom + 60,
                    alignment: .topLeading
                )
                .background(.accent)
                .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: -1)
            }
            .navigationTitle("JXB Map")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
            
        }
    }
}

#Preview {
    JXBMapView()
}
