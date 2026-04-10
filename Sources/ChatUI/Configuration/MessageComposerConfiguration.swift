import Foundation

/// Configuration values for the message composer.
public struct MessageComposerConfiguration {
    /// The placeholder text shown when the draft is empty.
    public var placeholder: String

    /// The maximum number of visible lines before scrolling.
    public var maxVisibleLines: Int

    /// The SF Symbol used for the send button.
    public var sendSymbolName: String

    /// Creates composer configuration.
    public init(
        placeholder: String = "iMessage",
        maxVisibleLines: Int = ChatMetrics.messages.composerVisibleLineCap,
        sendSymbolName: String = "arrow.up"
    ) {
        self.placeholder = placeholder
        self.maxVisibleLines = maxVisibleLines
        self.sendSymbolName = sendSymbolName
    }

    /// Default Messages-inspired composer configuration.
    public static let messages = MessageComposerConfiguration()
}
