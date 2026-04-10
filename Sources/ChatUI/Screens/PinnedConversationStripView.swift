import SwiftUI

/// A horizontal pinned conversation strip shown above the main conversation list.
public struct PinnedConversationStripView: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.chatAvatarRenderer) private var avatarRenderer
    @Environment(\.chatGroupAvatarRenderer) private var groupAvatarRenderer

    /// The pinned conversation previews.
    public var conversations: [ConversationPreview]

    /// Callback when a pinned conversation is selected.
    public var onOpenConversation: (ConversationPreview) -> Void

    /// Creates a pinned conversation strip view.
    public init(
        conversations: [ConversationPreview],
        onOpenConversation: @escaping (ConversationPreview) -> Void
    ) {
        self.conversations = conversations
        self.onOpenConversation = onOpenConversation
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(conversations) { conversation in
                    Button {
                        onOpenConversation(conversation)
                    } label: {
                        VStack(spacing: 8) {
                            pinnedAvatar(for: conversation)
                            Text(theme.formatters.conversationPreviewTitle(conversation))
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .frame(width: 70)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.metrics.transcriptHorizontalPadding)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private func pinnedAvatar(for conversation: ConversationPreview) -> some View {
        let others = conversation.participants.filter { $0.id != conversation.currentUserID }
        if conversation.kind == .group {
            groupAvatarRenderer.render(participants: others, size: 60)
        } else if let participant = others.first {
            avatarRenderer.render(participant: participant, size: 60)
        }
    }
}

#Preview("Pinned Strip") {
    PinnedConversationStripView(
        conversations: ChatPreviewFixtures.listPreviews.filter(\.isPinned),
        onOpenConversation: { _ in }
    )
    .chatTheme(.messages)
    .padding(.vertical)
}
