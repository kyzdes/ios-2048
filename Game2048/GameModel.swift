import SwiftUI

enum MoveDirection {
    case up, down, left, right
}

struct TileModel: Identifiable, Equatable {
    let id: UUID
    var value: Int
    var row: Int
    var col: Int

    init(value: Int, row: Int, col: Int) {
        self.id = UUID()
        self.value = value
        self.row = row
        self.col = col
    }
}

@MainActor
class GameModel: ObservableObject {
    @Published var tiles: [TileModel] = []
    @Published var score: Int = 0
    @Published var bestScore: Int = 0
    @Published var isGameOver: Bool = false
    @Published var hasWon: Bool = false
    @Published var keepPlaying: Bool = false
    @Published private(set) var isAnimating: Bool = false

    let size = 4

    init() {
        bestScore = UserDefaults.standard.integer(forKey: "best2048")
        newGame()
    }

    func newGame() {
        tiles = []
        score = 0
        isGameOver = false
        hasWon = false
        keepPlaying = false
        isAnimating = false
        spawnTile()
        spawnTile()
    }

    func continueAfterWin() {
        keepPlaying = true
        hasWon = false
    }

    // MARK: - Move

    func move(_ direction: MoveDirection) {
        guard !isAnimating else { return }

        let animationsEnabled = !UserDefaults.standard.bool(forKey: GamePreferenceKey.disableTileAnimations)
        let moveAnimationDuration = animationsEnabled ? 0.1 : 0.0

        struct TileChange {
            var row: Int
            var col: Int
            var value: Int
        }

        var changes: [UUID: TileChange] = [:]
        var toRemove: Set<UUID> = []
        var scoreGain = 0
        var anyMoved = false

        for lineIdx in 0..<size {
            let line: [TileModel]
            switch direction {
            case .left:  line = tiles.filter { $0.row == lineIdx }.sorted { $0.col < $1.col }
            case .right: line = tiles.filter { $0.row == lineIdx }.sorted { $0.col > $1.col }
            case .up:    line = tiles.filter { $0.col == lineIdx }.sorted { $0.row < $1.row }
            case .down:  line = tiles.filter { $0.col == lineIdx }.sorted { $0.row > $1.row }
            }

            var writePos = 0
            var j = 0

            while j < line.count {
                let pos = targetPosition(writePos: writePos, lineIndex: lineIdx, direction: direction)

                if j + 1 < line.count && line[j].value == line[j + 1].value {
                    let merged = line[j].value * 2
                    scoreGain += merged

                    changes[line[j].id] = TileChange(row: pos.row, col: pos.col, value: merged)
                    changes[line[j + 1].id] = TileChange(row: pos.row, col: pos.col, value: line[j + 1].value)
                    toRemove.insert(line[j + 1].id)
                    anyMoved = true
                    j += 2
                } else {
                    changes[line[j].id] = TileChange(row: pos.row, col: pos.col, value: line[j].value)
                    if line[j].row != pos.row || line[j].col != pos.col {
                        anyMoved = true
                    }
                    j += 1
                }
                writePos += 1
            }
        }

        guard anyMoved else { return }

        isAnimating = true

        if animationsEnabled {
            withAnimation(.easeInOut(duration: moveAnimationDuration)) {
                var updated = tiles
                for i in updated.indices {
                    if let change = changes[updated[i].id] {
                        updated[i].row = change.row
                        updated[i].col = change.col
                        updated[i].value = change.value
                    }
                }
                tiles = updated
            }
        } else {
            var updated = tiles
            for i in updated.indices {
                if let change = changes[updated[i].id] {
                    updated[i].row = change.row
                    updated[i].col = change.col
                    updated[i].value = change.value
                }
            }
            tiles = updated
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + moveAnimationDuration) { [weak self] in
            guard let self else { return }

            self.tiles.removeAll { toRemove.contains($0.id) }
            self.score += scoreGain

            if self.score > self.bestScore {
                self.bestScore = self.score
                UserDefaults.standard.set(self.bestScore, forKey: "best2048")
            }

            if animationsEnabled {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    self.spawnTile()
                }
            } else {
                self.spawnTile()
            }

            if self.tiles.contains(where: { $0.value >= 2048 }) && !self.hasWon && !self.keepPlaying {
                self.hasWon = true
            }

            if !self.canMove() {
                self.isGameOver = true
            }

            self.isAnimating = false
        }
    }

    // MARK: - Helpers

    private func targetPosition(writePos: Int, lineIndex: Int, direction: MoveDirection) -> (row: Int, col: Int) {
        switch direction {
        case .left:  return (lineIndex, writePos)
        case .right: return (lineIndex, size - 1 - writePos)
        case .up:    return (writePos, lineIndex)
        case .down:  return (size - 1 - writePos, lineIndex)
        }
    }

    private func spawnTile() {
        let occupied = Set(tiles.map { $0.row * size + $0.col })
        var empty: [(Int, Int)] = []
        for r in 0..<size {
            for c in 0..<size {
                if !occupied.contains(r * size + c) {
                    empty.append((r, c))
                }
            }
        }
        guard let pos = empty.randomElement() else { return }
        let value = Double.random(in: 0..<1) < 0.9 ? 2 : 4
        tiles.append(TileModel(value: value, row: pos.0, col: pos.1))
    }

    private func canMove() -> Bool {
        if tiles.count < size * size { return true }

        var grid = Array(repeating: Array(repeating: 0, count: size), count: size)
        for t in tiles { grid[t.row][t.col] = t.value }

        for r in 0..<size {
            for c in 0..<size {
                if r + 1 < size && grid[r][c] == grid[r + 1][c] { return true }
                if c + 1 < size && grid[r][c] == grid[r][c + 1] { return true }
            }
        }
        return false
    }
}
