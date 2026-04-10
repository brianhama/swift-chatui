import SwiftUI

/// A Messages-inspired conversation list row.
public struct ConversationRowView: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.chatAvatarRenderer) private var avatarRenderer
    @Environment(\.chatGroupAvatarRenderer) private var groupAvatarRenderer
    @Environment(\.chatConversationRowAccessoryRenderer) private var accessoryRenderer

    /// The preview displayed by the row.
    public var conversation: ConversationPreview

    /// Configuration for the list screen.
    public var configuration: ConversationListConfiguration

    /// Creates a conversation row view.
    public init(
        conversation: ConversationPreview,
        configuration: ConversationListConfiguration = .messages
    ) {
        self.conversation = conversation
        self.configuration = configuration
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(theme.formatters.conversationPreviewTitle(conversation))
                        .font(theme.typography.conversationTitle)
                        .fontWeight(conversation.unreadCount > 0 ? .semibold : .regular)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(theme.formatters.conversationTimestamp(conversation.latestActivityAt, Date()))
                        .font(.caption)
                        .foregroundStyle(theme.colors.metadata)
                }

                HStack(alignment: .center, spacing: 6) {
                    if conversation.unreadCount > 0 {
                        Circle()
                            .fill(theme.colors.accent)
                            .frame(width: 8, height: 8)
                    }

                    Text(previewText)
                        .font(theme.typography.conversationPreview)
                        .foregroundStyle(theme.colors.metadata)
                        .lineLimit(configuration.previewLineLimit)

                    Spacer(minLength: 6)

                    if conversation.isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.caption)
                            .foregroundStyle(theme.colors.metadata)
                    }

                    if conversation.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(theme.colors.metadata)
                    }

                    if let accessory = accessoryRenderer.render(preview: conversation) {
                        accessory
                    }
                }
            }
        }
        .frame(minHeight: theme.metrics.conversationRowMinHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    private var avatar: some View {
        Group {
            if conversation.kind == .group {
                groupAvatarRenderer.render(
                    participants: displayParticipants,
                    size: theme.metrics.groupConversationAvatarSize
                )
            } else if let participant = displayParticipants.first {
                avatarRenderer.render(
                    participant: participant,
                    size: theme.metrics.conversationAvatarSize
                )
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
                    .frame(width: theme.metrics.conversationAvatarSize, height: theme.metrics.conversationAvatarSize)
            }
        }
    }

    private var displayParticipants: [ChatParticipant] {
        conversation.participants.filter { $0.id != conversation.currentUserID }
    }

    private var previewText: String {
        if let draftPreview = conversation.draftPreview, draftPreview.isEmpty == false {
            return "Draft: \(draftPreview)"
        }
        return conversation.latestMessagePreview
    }

    private var accessibilityLabel: String {
        let unread = conversation.unreadCount > 0 ? ", unread" : ""
        let muted = conversation.isMuted ? ", muted" : ""
        let time = theme.formatters.conversationTimestamp(conversation.latestActivityAt, Date())
        return "\(theme.formatters.conversationPreviewTitle(conversation))\(unread)\(muted), \(previewText), \(time)"
    }
}

#Preview("Conversation Row") {
    ConversationRowView(conversation: ChatPreviewFixtures.listPreviews[0])
        .chatTheme(.messages)
        .padding()
}
