import SwiftUI

struct BoardView: View {
    @ObservedObject var game: GameModel
    @Environment(\.colorScheme) private var colorScheme

    private let spacing: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height)
            let cellSize = (boardSize - spacing * CGFloat(game.size + 1)) / CGFloat(game.size)
            let palette = GamePalette.palette(for: colorScheme)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.boardBackground)

                ForEach(0..<game.size, id: \.self) { row in
                    ForEach(0..<game.size, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(palette.cellBackground)
                            .frame(width: cellSize, height: cellSize)
                            .position(
                                x: cellX(col: col, cellSize: cellSize),
                                y: cellY(row: row, cellSize: cellSize)
                            )
                    }
                }

                ForEach(game.tiles) { tile in
                    TileView(value: tile.value, size: cellSize)
                        .position(
                            x: cellX(col: tile.col, cellSize: cellSize),
                            y: cellY(row: tile.row, cellSize: cellSize)
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.1).combined(with: .opacity),
                            removal: .opacity.animation(.linear(duration: 0))
                        ))
                        .zIndex(Double(tile.value))
                }
            }
            .frame(width: boardSize, height: boardSize)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cellX(col: Int, cellSize: CGFloat) -> CGFloat {
        spacing + cellSize / 2 + CGFloat(col) * (cellSize + spacing)
    }

    private func cellY(row: Int, cellSize: CGFloat) -> CGFloat {
        spacing + cellSize / 2 + CGFloat(row) * (cellSize + spacing)
    }
}
