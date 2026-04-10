import SwiftUI

/// Semantic colors used throughout the chat UI.
public struct ChatColors {
    /// The primary transcript background color.
    public var transcriptBackground: Color

    /// The outgoing bubble fill color.
    public var outgoingBubble: Color

    /// The incoming bubble fill color.
    public var incomingBubble: Color

    /// The primary text color used on outgoing bubbles.
    public var outgoingText: Color

    /// The primary text color used on incoming bubbles.
    public var incomingText: Color

    /// Secondary metadata text color.
    public var metadata: Color

    /// Accent color for unread indicators and send controls.
    public var accent: Color

    /// Bubble fill for the typing indicator.
    public var typingBubble: Color

    /// Composer chrome background.
    public var composerBackground: Color

    /// Composer field background.
    public var composerFieldBackground: Color

    /// Failure highlight color.
    public var destructive: Color

    /// Creates a semantic color palette.
    public init(
        transcriptBackground: Color,
        outgoingBubble: Color,
        incomingBubble: Color,
        outgoingText: Color,
        incomingText: Color,
        metadata: Color,
        accent: Color,
        typingBubble: Color,
        composerBackground: Color,
        composerFieldBackground: Color,
        destructive: Color
    ) {
        self.transcriptBackground = transcriptBackground
        self.outgoingBubble = outgoingBubble
        self.incomingBubble = incomingBubble
        self.outgoingText = outgoingText
        self.incomingText = incomingText
        self.metadata = metadata
        self.accent = accent
        self.typingBubble = typingBubble
        self.composerBackground = composerBackground
        self.composerFieldBackground = composerFieldBackground
        self.destructive = destructive
    }

    /// A Messages-like default palette.
    public static let messages = ChatColors(
        transcriptBackground: Color(uiColor: .systemBackground),
        outgoingBubble: Color(uiColor: .systemBlue),
        incomingBubble: Color(uiColor: .secondarySystemFill),
        outgoingText: .white,
        incomingText: Color(uiColor: .label),
        metadata: Color(uiColor: .secondaryLabel),
        accent: Color(uiColor: .systemBlue),
        typingBubble: Color(uiColor: .secondarySystemFill),
        composerBackground: Color(uiColor: .systemBackground),
        composerFieldBackground: Color(uiColor: .secondarySystemBackground),
        destructive: Color(uiColor: .systemRed)
    )
}
