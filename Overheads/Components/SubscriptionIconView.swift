//
//  SubscriptionIconView.swift
//  Overheads
//
//  Created by Codex on 4/23/26.
//

import SwiftUI
import UIKit

struct SubscriptionIconView: View {
    @Environment(\.colorScheme) private var colorScheme
    let customization: Subscription.IconCustomization?
    let side: CGFloat
    let symbolSide: CGFloat

    var body: some View {
        ZStack {
            iconContent
                .scaleEffect(iconScale)
        }
        .frame(width: side, height: side)
        .background(circleBackground)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(circleBorderColor, lineWidth: 0.9)
        )
        .shadow(color: shadowColor, radius: side * 0.12, y: side * 0.08)
    }

    @ViewBuilder
    private var iconContent: some View {
        if let uploadedIcon = uploadedUIImage {
            Image(uiImage: uploadedIcon)
                .resizable()
                .scaledToFill()
                .frame(width: side, height: side)
                .clipped()
        } else {
            Image(systemName: "photo.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: symbolSide * 0.84, height: symbolSide * 0.84)
                .foregroundStyle(foregroundColor)
        }
    }

    private var iconScale: CGFloat {
        CGFloat(customization?.scale ?? 1.0)
    }

    private var uploadedUIImage: UIImage? {
        guard
            let uploadedImageData = customization?.uploadedImageData,
            let image = UIImage(data: uploadedImageData)
        else {
            return nil
        }

        return image
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }

    private var circleBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [palette.iconTop, palette.iconBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var circleBorderColor: Color {
        palette.iconBorder
    }

    private var foregroundColor: Color {
        palette.iconSymbol
    }

    private var shadowColor: Color {
        palette.raisedShadow.opacity(palette.isDark ? 0.8 : 0.45)
    }
}
