//
//  IconCustomizationCard.swift
//  Overheads
//
//  Created by Codex on 4/23/26.
//

import PhotosUI
import SwiftUI
import UIKit

struct IconCustomizationCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var uploadedImageData: Data?
    @Binding var scale: Double

    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                SubscriptionIconView(
                    customization: liveCustomization,
                    side: 70,
                    symbolSide: 40
                )
                .frame(width: 70, height: 70)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(uploadedImageData == nil ? "Upload Icon" : "Replace Icon")
                            .font(AddSubscriptionFont.bodySemibold(15))
                    }
                    .foregroundStyle(palette.actionTextOnSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(buttonFill(colors: palette.secondaryActionColors))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack(spacing: 10) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(palette.placeholderText)

                Slider(value: $scale, in: 0.8...1.2, step: 0.02)
                    .tint(palette.sun)

                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(palette.secondaryText)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background {
            OverheadsRoundedPanelBackground(
                palette: palette,
                cornerRadius: 30,
                emphasis: 0.8
            )
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else { return }

            Task {
                guard let loadedData = try? await newValue.loadTransferable(type: Data.self) else { return }
                uploadedImageData = preparedImageData(from: loadedData)
            }
        }
    }

    private var liveCustomization: Subscription.IconCustomization {
        Subscription.IconCustomization(
            uploadedImageData: uploadedImageData,
            scale: scale
        )
    }

    private var palette: OverheadsTheme {
        OverheadsTheme.resolve(for: colorScheme)
    }

    private func buttonFill(colors: [Color]) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [palette.cream.opacity(palette.isDark ? 0.10 : 0.18), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(palette.panelStroke, lineWidth: 0.8)
            }
    }

    private func preparedImageData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxDimension: CGFloat = 600
        let longestSide = max(image.size.width, image.size.height)
        let scaleRatio = min(1, maxDimension / max(longestSide, 1))
        let targetSize = CGSize(
            width: image.size.width * scaleRatio,
            height: image.size.height * scaleRatio
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resizedImage.pngData()
    }
}
