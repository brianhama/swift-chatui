import CoreGraphics
import Foundation

/// Configuration values for the chat thread experience.
public struct ChatThreadConfiguration {
    /// The grouping threshold in seconds.
    public var groupingThreshold: TimeInterval

    /// The date separator rule.
    public var dateSeparatorStrategy: DateSeparatorStrategy

    /// Whether transcript avatars should be shown in direct chats.
    public var showsDirectChatAvatars: Bool

    /// Whether the jump-to-latest affordance is enabled.
    public var showsJumpToLatest: Bool

    /// The distance from the bottom before the jump button appears.
    public var jumpToLatestThreshold: CGFloat

    /// The embedded composer configuration.
    public var composer: MessageComposerConfiguration

    /// Additional context menu actions supplied by the host.
    public var messageContextMenuActions: (ChatMessage, MessageRowContext) -> [ChatContextMenuAction]

    /// Creates thread configuration.
    public init(
        groupingThreshold: TimeInterval = 5 * 60,
        dateSeparatorStrategy: DateSeparatorStrategy = .dayChange,
        showsDirectChatAvatars: Bool = false,
        showsJumpToLatest: Bool = true,
        jumpToLatestThreshold: CGFloat = ChatMetrics.messages.jumpToLatestThreshold,
        composer: MessageComposerConfiguration = .messages,
        messageContextMenuActions: @escaping (ChatMessage, MessageRowContext) -> [ChatContextMenuAction] = { _, _ in [] }
    ) {
        self.groupingThreshold = groupingThreshold
        self.dateSeparatorStrategy = dateSeparatorStrategy
        self.showsDirectChatAvatars = showsDirectChatAvatars
        self.showsJumpToLatest = showsJumpToLatest
        self.jumpToLatestThreshold = jumpToLatestThreshold
        self.composer = composer
        self.messageContextMenuActions = messageContextMenuActions
    }

    /// Default Messages-inspired thread configuration.
    public static let messages = ChatThreadConfiguration()
}
