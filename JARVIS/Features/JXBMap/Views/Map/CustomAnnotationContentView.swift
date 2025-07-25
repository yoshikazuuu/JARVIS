//
//  CustomAnnotationContentView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 25/07/25.
//

import SwiftUI

struct CustomAnnotationContentView: View {
    let booth: Booth
    let onNavigateTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: booth.boothType == .experience ? "star.fill" : "briefcase.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        booth.boothType == .experience
                            ? Color.orange.gradient
                            : Color.accent.gradient
                    )
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(booth.name)
                        .font(.mulish(15, .bold))
                        .lineLimit(1)
                        .foregroundStyle(.text)

                    if !booth.location.isEmpty && booth.location != "Unknown" {
                        Text(booth.location)
                            .font(.mulish(12))
                            .lineLimit(1)
                            .foregroundStyle(.textSecondary)
                    }
                }
                
                Spacer()
            }

            Button(action: onNavigateTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                    
                    Text("NAVIGATE")
                        .font(.mulish(12, .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            Triangle()
                .fill(Color.white)
                .frame(width: 16, height: 8)
                .offset(y: 6),
            alignment: .bottom
        )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
