//
//  BoothRowView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 24/07/25.
//

import SwiftUI

struct BoothRowView: View {
    let booth: Booth
    let isInSearch: Bool

    init(booth: Booth, isInSearch: Bool = false) {
        self.booth = booth
        self.isInSearch = isInSearch
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                Image(
                    systemName: booth.boothType == .experience
                        ? "star.fill" : "handbag.fill"
                )
                .foregroundStyle(.primaryRed)
                .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(booth.name)
                        .font(.mulish(14, .semibold))
                    Text(booth.location)
                        .font(.mulish(13))
                        .foregroundStyle(.textSecondary)
                }
            }

            if !isInSearch {
                Divider()
                    .padding(.top, 16)
                    .padding(.leading, 34)
            }
        }
        .padding(.bottom, isInSearch ? 0 : 16)
    }
}
