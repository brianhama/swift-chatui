import SwiftUI

/// A circular participant avatar with initials fallback.
public struct AvatarView: View {
    @Environment(\.chatTheme) private var theme

    /// The participant shown by the avatar.
    public var participant: ChatParticipant

    /// The rendered avatar size.
    public var size: CGFloat

    /// Creates an avatar view.
    public init(participant: ChatParticipant, size: CGFloat = ChatMetrics.messages.conversationAvatarSize) {
        self.participant = participant
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(AccentColorPalette.color(for: participant.accentColorToken))
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
            .accessibilityElement()
            .accessibilityLabel(Text(participant.accessibilityName ?? participant.displayName))
    }

    private var initials: String {
        if let initials = participant.initials, initials.isEmpty == false {
            return initials
        }

        let components = participant.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)

        let resolved = String(components)
        return resolved.isEmpty ? "?" : resolved.uppercased()
    }
}

#Preview("Avatar") {
    AvatarView(
        participant: ChatParticipant(id: "sam", displayName: "Sam Rivera", initials: "SR", accentColorToken: "sam"),
        size: 56
    )
    .padding()
}
