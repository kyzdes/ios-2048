import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameModel()
    @Environment(\.colorScheme) private var colorScheme

    #if os(macOS)
    @AppStorage(GamePreferenceKey.invertHorizontalTrackpadSwipes)
    private var invertHorizontalTrackpadSwipes = false
    #endif

    var body: some View {
        let palette = GamePalette.palette(for: colorScheme)

        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                subtitle
                board
                instructions
                Spacer()
            }
            .frame(maxWidth: 560)
            .padding(20)
            .background {
                #if os(macOS)
                MacTrackpadInputBridge(
                    invertHorizontalSwipeDirection: invertHorizontalTrackpadSwipes,
                    onMove: performMove
                )
                #endif
            }

            if game.isGameOver {
                gameOverOverlay
            }

            if game.hasWon {
                winOverlay
            }
        }
    }

    private var palette: GamePalette {
        GamePalette.palette(for: colorScheme)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            Text("2048")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(palette.primaryText)

            Spacer()

            HStack(spacing: 6) {
                ScoreBox(title: "SCORE", value: game.score)
                ScoreBox(title: "BEST", value: game.bestScore)
            }
        }
    }

    private var subtitle: some View {
        HStack {
            Text("Join the tiles, get to **2048**!")
                .font(.system(size: 15))
                .foregroundColor(palette.primaryText)

            Spacer()

            HStack(spacing: 8) {
                #if os(macOS)
                SettingsLink {
                    Text("Settings")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(palette.primaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(palette.cellBackground)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                #endif

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        game.newGame()
                    }
                } label: {
                    Text("New Game")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(palette.buttonBackground)
                        .cornerRadius(6)
                }
            }
        }
    }

    // MARK: - Board + Gestures

    @ViewBuilder
    private var board: some View {
        #if os(iOS)
        BoardView(game: game)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        if abs(h) > abs(v) {
                            performMove(h > 0 ? .right : .left)
                        } else {
                            performMove(v > 0 ? .down : .up)
                        }
                    }
            )
        #else
        BoardView(game: game)
        #endif
    }

    @ViewBuilder
    private var instructions: some View {
        #if os(macOS)
        VStack(spacing: 4) {
            Text("Swipe with two fingers on the trackpad or use arrow keys / WASD.")
            Text("Open settings with Cmd+, or the Settings button.")
        }
        .font(.system(size: 13))
        .foregroundColor(palette.secondaryText)
        .multilineTextAlignment(.center)
        .padding(.top, 8)
        #else
        Text("Swipe to move tiles. Equal tiles merge into one!")
            .font(.system(size: 13))
            .foregroundColor(palette.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
        #endif
    }

    // MARK: - Overlays

    private var gameOverOverlay: some View {
        ZStack {
            palette.gameOverOverlay
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Game Over!")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(palette.primaryText)

                Text("Score: \(game.score)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(palette.primaryText)

                Button {
                    withAnimation {
                        game.newGame()
                    }
                } label: {
                    Text("Try Again")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(palette.buttonBackground)
                        .cornerRadius(8)
                }
            }
        }
        .transition(.opacity)
    }

    private var winOverlay: some View {
        ZStack {
            palette.winOverlay
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("You Win!")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Score: \(game.score)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 12) {
                    Button {
                        withAnimation {
                            game.continueAfterWin()
                        }
                    } label: {
                        Text("Keep Going")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(palette.primaryText)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.white)
                            .cornerRadius(8)
                    }

                    Button {
                        withAnimation {
                            game.newGame()
                        }
                    } label: {
                        Text("New Game")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(palette.buttonBackground)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .transition(.opacity)
    }

    private var acceptsInput: Bool {
        !game.isGameOver && (!game.hasWon || game.keepPlaying)
    }

    private func performMove(_ direction: MoveDirection) {
        guard acceptsInput else { return }
        game.move(direction)
    }
}

// MARK: - Score Box

struct ScoreBox: View {
    let title: String
    let value: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = GamePalette.palette(for: colorScheme)

        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(palette.scoreLabel)

            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(minWidth: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(palette.scoreBackground)
        .cornerRadius(6)
    }
}
