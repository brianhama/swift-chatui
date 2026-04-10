import Foundation

/// Configuration values for the conversation list screen.
public struct ConversationListConfiguration {
    /// Whether a pinned strip is shown when pinned rows exist.
    public var showsPinnedSection: Bool

    /// The title shown for the empty state.
    public var emptyStateTitle: String

    /// Secondary empty-state copy.
    public var emptyStateMessage: String?

    /// The line limit used for previews.
    public var previewLineLimit: Int

    /// Creates conversation list configuration.
    public init(
        showsPinnedSection: Bool = true,
        emptyStateTitle: String = "No Conversations",
        emptyStateMessage: String? = "Your conversations will appear here.",
        previewLineLimit: Int = 1
    ) {
        self.showsPinnedSection = showsPinnedSection
        self.emptyStateTitle = emptyStateTitle
        self.emptyStateMessage = emptyStateMessage
        self.previewLineLimit = previewLineLimit
    }

    /// Default Messages-inspired list configuration.
    public static let messages = ConversationListConfiguration()
}
