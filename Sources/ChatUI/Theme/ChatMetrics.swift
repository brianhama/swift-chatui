import CoreGraphics

/// Sizing, spacing, and geometry constants used by the chat UI.
public struct ChatMetrics {
    /// Minimum height for a conversation row.
    public var conversationRowMinHeight: CGFloat

    /// Avatar size used for direct conversation rows.
    public var conversationAvatarSize: CGFloat

    /// Avatar size used for group conversation rows.
    public var groupConversationAvatarSize: CGFloat

    /// Horizontal transcript padding.
    public var transcriptHorizontalPadding: CGFloat

    /// Vertical spacing between rows inside a message run.
    public var messageRunSpacing: CGFloat

    /// Vertical spacing between message runs.
    public var messageGroupSpacing: CGFloat

    /// Top spacing above date separators.
    public var dateSeparatorTopSpacing: CGFloat

    /// Bottom spacing below date separators.
    public var dateSeparatorBottomSpacing: CGFloat

    /// Avatar size in the transcript.
    public var transcriptAvatarSize: CGFloat

    /// Bubble width ratio in compact width environments.
    public var bubbleMaxWidthCompact: CGFloat

    /// Bubble width ratio in regular width environments.
    public var bubbleMaxWidthRegular: CGFloat

    /// Outer bubble corner radius.
    public var bubbleCornerRadius: CGFloat

    /// Inner grouped bubble corner radius.
    public var groupedInnerCornerRadius: CGFloat

    /// Minimum composer field height.
    public var composerFieldMinHeight: CGFloat

    /// Maximum number of visible composer lines.
    public var composerVisibleLineCap: Int

    /// Distance from bottom before the jump button appears.
    public var jumpToLatestThreshold: CGFloat

    /// Creates chat metrics.
    public init(
        conversationRowMinHeight: CGFloat,
        conversationAvatarSize: CGFloat,
        groupConversationAvatarSize: CGFloat,
        transcriptHorizontalPadding: CGFloat,
        messageRunSpacing: CGFloat,
        messageGroupSpacing: CGFloat,
        dateSeparatorTopSpacing: CGFloat,
        dateSeparatorBottomSpacing: CGFloat,
        transcriptAvatarSize: CGFloat,
        bubbleMaxWidthCompact: CGFloat,
        bubbleMaxWidthRegular: CGFloat,
        bubbleCornerRadius: CGFloat,
        groupedInnerCornerRadius: CGFloat,
        composerFieldMinHeight: CGFloat,
        composerVisibleLineCap: Int,
        jumpToLatestThreshold: CGFloat
    ) {
        self.conversationRowMinHeight = conversationRowMinHeight
        self.conversationAvatarSize = conversationAvatarSize
        self.groupConversationAvatarSize = groupConversationAvatarSize
        self.transcriptHorizontalPadding = transcriptHorizontalPadding
        self.messageRunSpacing = messageRunSpacing
        self.messageGroupSpacing = messageGroupSpacing
        self.dateSeparatorTopSpacing = dateSeparatorTopSpacing
        self.dateSeparatorBottomSpacing = dateSeparatorBottomSpacing
        self.transcriptAvatarSize = transcriptAvatarSize
        self.bubbleMaxWidthCompact = bubbleMaxWidthCompact
        self.bubbleMaxWidthRegular = bubbleMaxWidthRegular
        self.bubbleCornerRadius = bubbleCornerRadius
        self.groupedInnerCornerRadius = groupedInnerCornerRadius
        self.composerFieldMinHeight = composerFieldMinHeight
        self.composerVisibleLineCap = composerVisibleLineCap
        self.jumpToLatestThreshold = jumpToLatestThreshold
    }

    /// Default Messages-inspired metrics.
    public static let messages = ChatMetrics(
        conversationRowMinHeight: 72,
        conversationAvatarSize: 48,
        groupConversationAvatarSize: 52,
        transcriptHorizontalPadding: 12,
        messageRunSpacing: 2,
        messageGroupSpacing: 8,
        dateSeparatorTopSpacing: 18,
        dateSeparatorBottomSpacing: 10,
        transcriptAvatarSize: 28,
        bubbleMaxWidthCompact: 0.74,
        bubbleMaxWidthRegular: 0.60,
        bubbleCornerRadius: 20,
        groupedInnerCornerRadius: 8,
        composerFieldMinHeight: 36,
        composerVisibleLineCap: 6,
        jumpToLatestThreshold: 120
    )
}
