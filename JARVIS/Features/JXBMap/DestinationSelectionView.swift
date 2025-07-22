//
//  DestinationSelectionView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

import SwiftUI

struct BoothRowView: View {
    let booth: Booth
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: booth.boothType == .experience ? "star.fill" : "handbag.fill")
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
    }
}

struct DestinationSelectionView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let examples = Booth.examples
        
        ZStack(alignment: .top) {
            Color.surface.ignoresSafeArea()
            VStack(alignment: .center, spacing: 20) {
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
                        Text("Azzura")
                            .font(.mulish(14, .semibold))
                        Text("Hall A")
                            .font(.mulish(13))
                            .foregroundStyle(.textSecondary)

                        Divider()

                        Text("Avoskin")
                            .font(.mulish(14, .semibold))
                        Text("Hall A")
                            .font(.mulish(13))
                            .foregroundStyle(.textSecondary)
                    }
                }
                .padding(12)
                .foregroundStyle(.text)
                .background {
                    Color.white
                }
                .clipShape(.rect(cornerRadius: 4))
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Suggestion for you")
                            .font(.mulish(12))
                            .foregroundStyle(.textSecondary.opacity(0.7))
                        
                        Spacer()
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(examples, id: \.name) { booth in
                                BoothRowView(booth: booth)
                            }
                        }
                    }
                }
                .padding(12)
                .foregroundStyle(.text)
                .background {
                    Color.white
                }
                .clipShape(.rect(cornerRadius: 4))
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 0)
        }
    }
}

#Preview {
    DestinationSelectionView()
}
