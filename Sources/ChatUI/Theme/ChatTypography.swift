import SwiftUI

/// Text styles used by the chat UI.
public struct ChatTypography {
    /// The row title font.
    public var conversationTitle: Font

    /// The row preview font.
    public var conversationPreview: Font

    /// The message bubble font.
    public var bubble: Font

    /// The sender label font.
    public var senderLabel: Font

    /// The status text font.
    public var status: Font

    /// The date separator font.
    public var dateSeparator: Font

    /// The composer field font.
    public var composer: Font

    /// Creates typography values.
    public init(
        conversationTitle: Font,
        conversationPreview: Font,
        bubble: Font,
        senderLabel: Font,
        status: Font,
        dateSeparator: Font,
        composer: Font
    ) {
        self.conversationTitle = conversationTitle
        self.conversationPreview = conversationPreview
        self.bubble = bubble
        self.senderLabel = senderLabel
        self.status = status
        self.dateSeparator = dateSeparator
        self.composer = composer
    }

    /// Default Messages-inspired typography.
    public static let messages = ChatTypography(
        conversationTitle: .callout.weight(.semibold),
        conversationPreview: .subheadline,
        bubble: .body,
        senderLabel: .caption,
        status: .caption2,
        dateSeparator: .caption,
        composer: .body
    )
}
