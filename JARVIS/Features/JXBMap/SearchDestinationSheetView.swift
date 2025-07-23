//
//  SearchDestinationSheetView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

import SwiftUI

struct SearchDestinationSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var body: some View {
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
        
        Spacer()
    }

}

#Preview {
    SearchDestinationSheetView()
}
