import SwiftUI

struct TileView: View {
    let value: Int
    let size: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .overlay(
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(4)
            )
    }

    private var backgroundColor: Color {
        if colorScheme == .dark {
            switch value {
            case 2:    return Color(red: 0.882, green: 0.839, blue: 0.769)
            case 4:    return Color(red: 0.863, green: 0.757, blue: 0.592)
            case 8:    return Color(red: 0.949, green: 0.698, blue: 0.443)
            case 16:   return Color(red: 0.957, green: 0.561, blue: 0.333)
            case 32:   return Color(red: 0.961, green: 0.439, blue: 0.325)
            case 64:   return Color(red: 0.965, green: 0.325, blue: 0.196)
            case 128:  return Color(red: 0.894, green: 0.733, blue: 0.314)
            case 256:  return Color(red: 0.902, green: 0.694, blue: 0.239)
            case 512:  return Color(red: 0.906, green: 0.659, blue: 0.176)
            case 1024: return Color(red: 0.914, green: 0.624, blue: 0.122)
            case 2048: return Color(red: 0.925, green: 0.592, blue: 0.086)
            default:   return Color(red: 0.525, green: 0.471, blue: 0.369)
            }
        }

        switch value {
        case 2:    return Color(red: 0.933, green: 0.894, blue: 0.855)
        case 4:    return Color(red: 0.929, green: 0.878, blue: 0.784)
        case 8:    return Color(red: 0.949, green: 0.694, blue: 0.475)
        case 16:   return Color(red: 0.961, green: 0.584, blue: 0.388)
        case 32:   return Color(red: 0.965, green: 0.486, blue: 0.373)
        case 64:   return Color(red: 0.965, green: 0.369, blue: 0.231)
        case 128:  return Color(red: 0.929, green: 0.812, blue: 0.447)
        case 256:  return Color(red: 0.929, green: 0.800, blue: 0.380)
        case 512:  return Color(red: 0.929, green: 0.784, blue: 0.314)
        case 1024: return Color(red: 0.929, green: 0.773, blue: 0.247)
        case 2048: return Color(red: 0.929, green: 0.761, blue: 0.180)
        default:   return Color(red: 0.235, green: 0.227, blue: 0.196)
        }
    }

    private var textColor: Color {
        if colorScheme == .dark {
            switch value {
            case 2, 4:
                return Color(red: 0.208, green: 0.176, blue: 0.145)
            default:
                return Color(red: 0.988, green: 0.980, blue: 0.957)
            }
        }

        return value <= 4
            ? GamePalette.palette(for: colorScheme).primaryText
            : Color(red: 0.976, green: 0.965, blue: 0.949)
    }

    private var borderColor: Color {
        guard colorScheme == .dark else { return .clear }

        if value <= 4 {
            return Color.black.opacity(0.12)
        }

        return Color.white.opacity(0.06)
    }

    private var borderWidth: CGFloat {
        colorScheme == .dark ? 1 : 0
    }

    private var fontSize: CGFloat {
        switch value {
        case    0..<100:   return size * 0.45
        case  100..<1000:  return size * 0.35
        case 1000..<10000: return size * 0.28
        default:           return size * 0.22
        }
    }
}
