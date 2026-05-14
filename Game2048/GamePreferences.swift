import SwiftUI

enum GamePreferenceKey {
    static let invertHorizontalTrackpadSwipes = "invertHorizontalTrackpadSwipes"
    static let disableTileAnimations = "disableTileAnimations"
    static let prefersDarkTheme = "prefersDarkTheme"
}

struct GamePalette {
    let background: Color
    let primaryText: Color
    let secondaryText: Color
    let boardBackground: Color
    let cellBackground: Color
    let scoreBackground: Color
    let scoreLabel: Color
    let buttonBackground: Color
    let gameOverOverlay: Color
    let winOverlay: Color

    static func palette(for colorScheme: ColorScheme) -> GamePalette {
        if colorScheme == .dark {
            return GamePalette(
                background: Color(red: 0.102, green: 0.102, blue: 0.118),
                primaryText: Color(red: 0.949, green: 0.925, blue: 0.871),
                secondaryText: Color(red: 0.827, green: 0.800, blue: 0.757),
                boardBackground: Color(red: 0.231, green: 0.224, blue: 0.255),
                cellBackground: Color(red: 0.302, green: 0.290, blue: 0.337),
                scoreBackground: Color(red: 0.251, green: 0.243, blue: 0.286),
                scoreLabel: Color(red: 0.784, green: 0.761, blue: 0.722),
                buttonBackground: Color(red: 0.698, green: 0.573, blue: 0.388),
                gameOverOverlay: Color.black.opacity(0.62),
                winOverlay: Color(red: 0.553, green: 0.431, blue: 0.102).opacity(0.82)
            )
        }

        return GamePalette(
            background: Color(red: 0.980, green: 0.973, blue: 0.937),
            primaryText: Color(red: 0.467, green: 0.431, blue: 0.396),
            secondaryText: Color(red: 0.467, green: 0.431, blue: 0.396).opacity(0.7),
            boardBackground: Color(red: 0.733, green: 0.678, blue: 0.627),
            cellBackground: Color(red: 0.804, green: 0.757, blue: 0.706),
            scoreBackground: Color(red: 0.733, green: 0.678, blue: 0.627),
            scoreLabel: Color(red: 0.933, green: 0.894, blue: 0.855),
            buttonBackground: Color(red: 0.561, green: 0.478, blue: 0.400),
            gameOverOverlay: Color(red: 0.980, green: 0.973, blue: 0.937).opacity(0.7),
            winOverlay: Color(red: 0.929, green: 0.761, blue: 0.180).opacity(0.6)
        )
    }
}
