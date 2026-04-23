//
//  OverheadsTheme.swift
//  Overheads
//
//  Created by Codex on 4/23/26.
//

import SwiftUI

struct OverheadsTheme {
    let isDark: Bool
    let ink: Color
    let sea: Color
    let cream: Color
    let sun: Color
    let ember: Color
    let backgroundBase: Color
    let panelTop: Color
    let panelBottom: Color
    let panelStroke: Color
    let panelHighlight: Color
    let raisedShadow: Color
    let edgeHighlight: Color
    let primaryText: Color
    let secondaryText: Color
    let mutedText: Color
    let divider: Color
    let placeholderText: Color
    let iconTop: Color
    let iconBottom: Color
    let iconBorder: Color
    let iconSymbol: Color
    let pickerFill: Color
    let subduedFill: Color

    static func resolve(for colorScheme: ColorScheme) -> OverheadsTheme {
        let ink = Color.overheadsInk
        let sea = Color.overheadsSea
        let cream = Color.overheadsCream
        let sun = Color.overheadsSun
        let ember = Color.overheadsEmber

        if colorScheme == .dark {
            return OverheadsTheme(
                isDark: true,
                ink: ink,
                sea: sea,
                cream: cream,
                sun: sun,
                ember: ember,
                backgroundBase: Color(hex: 0x08182D),
                panelTop: sea.opacity(0.40),
                panelBottom: ink.opacity(0.92),
                panelStroke: cream.opacity(0.16),
                panelHighlight: cream.opacity(0.12),
                raisedShadow: Color.black.opacity(0.34),
                edgeHighlight: sea.opacity(0.12),
                primaryText: cream.opacity(0.98),
                secondaryText: cream.opacity(0.76),
                mutedText: cream.opacity(0.56),
                divider: cream.opacity(0.18),
                placeholderText: cream.opacity(0.42),
                iconTop: sea.opacity(0.78),
                iconBottom: ink.opacity(0.98),
                iconBorder: cream.opacity(0.16),
                iconSymbol: cream.opacity(0.92),
                pickerFill: cream.opacity(0.10),
                subduedFill: sea.opacity(0.22)
            )
        }

        return OverheadsTheme(
            isDark: false,
            ink: ink,
            sea: sea,
            cream: cream,
            sun: sun,
            ember: ember,
            backgroundBase: cream.opacity(0.98),
            panelTop: cream.opacity(0.92),
            panelBottom: Color.white.opacity(0.52),
            panelStroke: ink.opacity(0.08),
            panelHighlight: Color.white.opacity(0.32),
            raisedShadow: ink.opacity(0.12),
            edgeHighlight: Color.white.opacity(0.46),
            primaryText: ink.opacity(0.96),
            secondaryText: ink.opacity(0.78),
            mutedText: sea.opacity(0.72),
            divider: ink.opacity(0.14),
            placeholderText: ink.opacity(0.34),
            iconTop: cream.opacity(0.96),
            iconBottom: sea.opacity(0.30),
            iconBorder: ink.opacity(0.08),
            iconSymbol: ink.opacity(0.86),
            pickerFill: Color.white.opacity(0.56),
            subduedFill: sea.opacity(0.12)
        )
    }

    var primaryActionColors: [Color] {
        [sun.opacity(isDark ? 1.0 : 0.96), ember.opacity(isDark ? 0.90 : 0.82)]
    }

    var secondaryActionColors: [Color] {
        [sea.opacity(isDark ? 0.98 : 0.94), ink.opacity(isDark ? 1.0 : 0.86)]
    }

    var neutralActionColors: [Color] {
        if isDark {
            return [cream.opacity(0.18), sea.opacity(0.22)]
        }

        return [cream.opacity(0.84), Color.white.opacity(0.54)]
    }

    var destructiveActionColors: [Color] {
        [ember.opacity(0.96), ink.opacity(isDark ? 0.96 : 0.82)]
    }

    var settledStatusColors: [Color] {
        [sea.opacity(0.96), ink.opacity(0.94)]
    }

    var attentionStatusColors: [Color] {
        [sun.opacity(0.98), ember.opacity(isDark ? 0.92 : 0.84)]
    }

    var actionTextOnAccent: Color {
        cream.opacity(0.96)
    }

    var actionTextOnSecondary: Color {
        cream.opacity(0.96)
    }

    var neutralActionText: Color {
        primaryText
    }
}

struct OverheadsScreenBackground: View {
    let palette: OverheadsTheme

    var body: some View {
        ZStack {
            palette.backgroundBase

            LinearGradient(
                colors: [
                    palette.ink.opacity(palette.isDark ? 0.92 : 0.18),
                    palette.sea.opacity(palette.isDark ? 0.52 : 0.12),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .center
            )

            LinearGradient(
                colors: [
                    .clear,
                    palette.sun.opacity(palette.isDark ? 0.14 : 0.10),
                    palette.ember.opacity(palette.isDark ? 0.18 : 0.12)
                ],
                startPoint: .top,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    palette.cream.opacity(palette.isDark ? 0.05 : 0.14),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

struct OverheadsRoundedPanelBackground: View {
    let palette: OverheadsTheme
    let cornerRadius: CGFloat
    var emphasis: CGFloat = 1.0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [palette.panelTop, palette.panelBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [palette.panelHighlight, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(palette.panelStroke, lineWidth: 0.9)
            }
            .shadow(
                color: palette.edgeHighlight,
                radius: palette.isDark ? 0 : 8,
                y: palette.isDark ? 0 : -1
            )
            .shadow(
                color: palette.raisedShadow,
                radius: 18 + (10 * emphasis),
                y: 10 + (6 * emphasis)
            )
    }
}

struct OverheadsCapsuleBackground: View {
    let palette: OverheadsTheme
    let colors: [Color]

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                palette.cream.opacity(palette.isDark ? 0.08 : 0.22),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay {
                Capsule()
                    .stroke(palette.panelStroke, lineWidth: 0.8)
            }
            .shadow(color: palette.raisedShadow, radius: 18, y: 10)
    }
}

struct OverheadsCircleBackground: View {
    let palette: OverheadsTheme
    let colors: [Color]

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                palette.cream.opacity(palette.isDark ? 0.10 : 0.20),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay {
                Circle()
                    .stroke(palette.panelStroke, lineWidth: 0.9)
            }
            .shadow(color: palette.raisedShadow, radius: 22, y: 16)
    }
}

extension Color {
    static let overheadsInk = Color(hex: 0x08254A)
    static let overheadsSea = Color(hex: 0x2B6484)
    static let overheadsCream = Color(hex: 0xF3EDC4)
    static let overheadsSun = Color(hex: 0xF78A16)
    static let overheadsEmber = Color(hex: 0xBA0912)

    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
