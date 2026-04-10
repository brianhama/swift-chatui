import Foundation

/// Formatter hooks used by the default UI.
public struct ChatFormatters {
    /// Formats thread titles.
    public var conversationTitle: (ChatConversation) -> String

    /// Formats list row titles.
    public var conversationPreviewTitle: (ConversationPreview) -> String

    /// Formats row timestamps.
    public var conversationTimestamp: (Date, Date) -> String

    /// Formats date separator labels.
    public var dateSeparator: (Date, Date) -> String

    /// Formats message status text.
    public var messageStatus: (MessageStatus) -> String

    /// Formats typing accessibility labels.
    public var typingAccessibilityLabel: ([TypingParticipant], [ChatParticipant]) -> String

    /// Creates formatter hooks.
    public init(
        conversationTitle: @escaping (ChatConversation) -> String,
        conversationPreviewTitle: @escaping (ConversationPreview) -> String,
        conversationTimestamp: @escaping (Date, Date) -> String,
        dateSeparator: @escaping (Date, Date) -> String,
        messageStatus: @escaping (MessageStatus) -> String,
        typingAccessibilityLabel: @escaping ([TypingParticipant], [ChatParticipant]) -> String
    ) {
        self.conversationTitle = conversationTitle
        self.conversationPreviewTitle = conversationPreviewTitle
        self.conversationTimestamp = conversationTimestamp
        self.dateSeparator = dateSeparator
        self.messageStatus = messageStatus
        self.typingAccessibilityLabel = typingAccessibilityLabel
    }

    /// Default Messages-inspired formatters.
    public static let messages: ChatFormatters = {
        let titleFormatter = ConversationTitleFormatter()
        let relative = RelativeDateLabelFormatter()
        return ChatFormatters(
            conversationTitle: { titleFormatter.title(for: $0) },
            conversationPreviewTitle: { titleFormatter.title(for: $0) },
            conversationTimestamp: { date, now in
                relative.timestampLabel(for: date, now: now)
            },
            dateSeparator: { date, now in
                relative.separatorLabel(for: date, now: now)
            },
            messageStatus: { status in
                switch status {
                case .sending:
                    return "Sending…"
                case .sent:
                    return "Sent"
                case .delivered:
                    return "Delivered"
                case .read:
                    return "Read"
                case .failed:
                    return "Not Delivered"
                }
            },
            typingAccessibilityLabel: { typingParticipants, participants in
                let names = typingParticipants.compactMap { typing in
                    participants.first(where: { $0.id == typing.participantID })?.displayName
                }
                switch names.count {
                case 0:
                    return "Typing"
                case 1:
                    return "\(names[0]) is typing"
                default:
                    return "\(names.joined(separator: ", ")) are typing"
                }
            }
        )
    }()
}
