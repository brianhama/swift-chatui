import SwiftUI

/// A Messages-like animated three-dot typing indicator.
public struct TypingIndicatorView: View {
    @Environment(\.chatTheme) private var theme
    @State private var phase = false

    /// The active typing participants.
    public var typingParticipants: [TypingParticipant]

    /// Conversation participants used for accessibility naming.
    public var participants: [ChatParticipant]

    /// Creates a typing indicator view.
    public init(typingParticipants: [TypingParticipant], participants: [ChatParticipant]) {
        self.typingParticipants = typingParticipants
        self.participants = participants
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            MessageBubbleShape(direction: .incoming, groupPosition: .single)
                .fill(theme.colors.typingBubble)
                .frame(width: 56, height: 34)
                .overlay {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(theme.colors.metadata.opacity(0.8))
                                .frame(width: 7, height: 7)
                                .scaleEffect(phase ? 1.0 : 0.7)
                                .opacity(phase ? 1.0 : 0.45)
                                .animation(
                                    theme.animations.typing.delay(Double(index) * 0.18),
                                    value: phase
                                )
                        }
                    }
                }
            Spacer(minLength: 0)
        }
        .onAppear { phase = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(theme.formatters.typingAccessibilityLabel(typingParticipants, participants)))
    }
}

#Preview("Typing") {
    TypingIndicatorView(
        typingParticipants: [TypingParticipant(id: "1", participantID: "sam", startedAt: .now)],
        participants: [
            ChatParticipant(id: "sam", displayName: "Sam", initials: "SA"),
            ChatParticipant(id: "alex", displayName: "Alex", initials: "AL")
        ]
    )
    .chatTheme(.messages)
    .padding()
}
