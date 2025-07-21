//
//  JXBMapView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 21/07/25.
//

import SwiftUI

struct JXBMapView: View {
    var body: some View {
        ZStack {
            MapView()
        }
        .navigationTitle("JXB Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JXBMapView()
}
