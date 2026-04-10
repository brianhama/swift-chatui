import SwiftUI

enum AccentColorPalette {
    static func color(for token: String?) -> Color {
        let palette: [Color] = [
            Color(red: 0.95, green: 0.45, blue: 0.33),
            Color(red: 0.20, green: 0.60, blue: 0.86),
            Color(red: 0.30, green: 0.73, blue: 0.46),
            Color(red: 0.91, green: 0.62, blue: 0.17),
            Color(red: 0.57, green: 0.42, blue: 0.83),
            Color(red: 0.18, green: 0.66, blue: 0.66),
            Color(red: 0.83, green: 0.29, blue: 0.48)
        ]
        guard let token, token.isEmpty == false else {
            return palette[0]
        }

        let hash = abs(token.hashValue)
        return palette[hash % palette.count]
    }
}
