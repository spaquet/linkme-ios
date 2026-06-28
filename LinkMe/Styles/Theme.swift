import SwiftUI

/// Design system color palette.
///
/// Includes neutrals (slate/ink), teal accent (on-device/AI signal), accents (amber, rose), and semantic colors (canvas, surface).
struct LinkMeColors {
    /// Headline and primary text color (#0f1720).
    static let ink = Color(#colorLiteral(red: 0.06, green: 0.09, blue: 0.13, alpha: 1)) // #0f1720
    static let s900 = Color(#colorLiteral(red: 0.07, green: 0.09, blue: 0.15, alpha: 1)) // #111827
    static let s800 = Color(#colorLiteral(red: 0.12, green: 0.16, blue: 0.22, alpha: 1)) // #1f2937
    static let s700 = Color(#colorLiteral(red: 0.22, green: 0.25, blue: 0.32, alpha: 1)) // #374151
    static let s600 = Color(#colorLiteral(red: 0.29, green: 0.33, blue: 0.39, alpha: 1)) // #4b5563
    static let s500 = Color(#colorLiteral(red: 0.42, green: 0.45, blue: 0.50, alpha: 1)) // #6b7280
    static let s400 = Color(#colorLiteral(red: 0.61, green: 0.64, blue: 0.69, alpha: 1)) // #9ca3af
    static let s300 = Color(#colorLiteral(red: 0.82, green: 0.84, blue: 0.86, alpha: 1)) // #d1d5db
    static let s200 = Color(#colorLiteral(red: 0.90, green: 0.91, blue: 0.92, alpha: 1)) // #e5e7eb
    static let s100 = Color(#colorLiteral(red: 0.95, green: 0.96, blue: 0.96, alpha: 1)) // #f3f4f6
    static let s50 = Color(#colorLiteral(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)) // #f9fafb

    // Teal accent (live/on-device/AI signal)
    static let t50 = Color(#colorLiteral(red: 0.94, green: 0.99, blue: 0.98, alpha: 1)) // #f0fdfa
    static let t100 = Color(#colorLiteral(red: 0.80, green: 0.98, blue: 0.95, alpha: 1)) // #ccfbf1
    static let t200 = Color(#colorLiteral(red: 0.60, green: 0.96, blue: 0.89, alpha: 1)) // #99f6e4
    static let t400 = Color(#colorLiteral(red: 0.18, green: 0.83, blue: 0.75, alpha: 1)) // #2dd4bf
    static let t500 = Color(#colorLiteral(red: 0.08, green: 0.72, blue: 0.65, alpha: 1)) // #14b8a6
    static let t600 = Color(#colorLiteral(red: 0.05, green: 0.58, blue: 0.53, alpha: 1)) // #0d9488
    static let t700 = Color(#colorLiteral(red: 0.06, green: 0.46, blue: 0.43, alpha: 1)) // #0f766e

    // Accents
    static let amber50 = Color(#colorLiteral(red: 1.00, green: 0.98, blue: 0.92, alpha: 1)) // #fffbeb
    static let amber100 = Color(#colorLiteral(red: 0.99, green: 0.95, blue: 0.78, alpha: 1)) // #fef3c7
    static let amber500 = Color(#colorLiteral(red: 0.96, green: 0.62, blue: 0.07, alpha: 1)) // #f59e0b
    static let amber600 = Color(#colorLiteral(red: 0.85, green: 0.47, blue: 0.04, alpha: 1)) // #d97706

    static let rose50 = Color(#colorLiteral(red: 1.00, green: 0.96, blue: 0.97, alpha: 1)) // #fff5f7
    static let rose400 = Color(#colorLiteral(red: 0.96, green: 0.25, blue: 0.37, alpha: 1)) // #f43f5e
    static let rose500 = Color(#colorLiteral(red: 0.88, green: 0.11, blue: 0.28, alpha: 1)) // #e11d48

    // Semantic
    static let white = Color.white
    static let canvas = Color(#colorLiteral(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)) // #f6f8f9
    static let surface = Color.white
}

/// Design system shadow definitions.
///
/// Three semantic shadows: sm (subtle), md (default), lg (elevation).
struct LinkMeShadows {
    /// Subtle shadow (1px blur).
    static let sm: [Double] = [0, 1, 2] // 0 1px 2px rgba(15,23,32,.05)

    /// Default shadow (dual layer for depth).
    static let md: [Double] = [0, 6, 16, -6, 0, 2, 5, -2] // dual shadow

    /// Elevation shadow (for floating elements).
    static let lg: [Double] = [0, 18, 40, -12, 0, 6, 14, -8] // dual shadow
}

/// Design system typography.
struct LinkMeTypography {
    /// Primary font family (Geist, 300-700 weight).
    static let fontFamily = "Geist"

    /// Monospace font family (Geist Mono).
    static let monoFamily = "Geist Mono"
}

/// Design system layout constants.
struct LinkMeLayout {
    /// Status bar height (56pt).
    static let statusBarHeight: CGFloat = 56

    /// Tab bar height (78pt).
    static let tabBarHeight: CGFloat = 78

    /// Home safe area inset (30pt).
    static let homeInset: CGFloat = 30

    /// Standard corner radius (16pt).
    static let cornerRadius: CGFloat = 16

    /// Card corner radius (18pt).
    static let cardRadius: CGFloat = 18
}

/// Central theme namespace for all design tokens.
///
/// Access colors, shadows, fonts, and layout constants via Theme.colors, Theme.shadows, etc.
struct Theme {
    /// Color palette.
    static let colors = LinkMeColors()

    /// Shadow definitions.
    static let shadows = LinkMeShadows()

    /// Typography settings.
    static let typography = LinkMeTypography()

    /// Layout constants.
    static let layout = LinkMeLayout()
}
