import SwiftUI

/// A high-level conversation list screen with pinned conversations, swipe actions, selection support, and an empty state.
public struct ConversationListScreen: View {
    /// The conversations shown by the screen.
    public var conversations: [ConversationPreview]

    /// Optional selection binding used in edit-mode-friendly contexts.
    public var selection: Binding<ConversationPreview.ID?>?

    /// Configuration for list behavior and copy.
    public var configuration: ConversationListConfiguration

    /// Callback when a conversation is selected.
    public var onOpenConversation: (ConversationPreview) -> Void

    /// Optional delete callback.
    public var onDeleteConversation: ((ConversationPreview) -> Void)?

    /// Optional mute toggle callback.
    public var onToggleMute: ((ConversationPreview) -> Void)?

    /// Optional read toggle callback.
    public var onToggleRead: ((ConversationPreview) -> Void)?

    /// Creates a conversation list screen.
    public init(
        conversations: [ConversationPreview],
        selection: Binding<ConversationPreview.ID?>? = nil,
        configuration: ConversationListConfiguration = .messages,
        onOpenConversation: @escaping (ConversationPreview) -> Void,
        onDeleteConversation: ((ConversationPreview) -> Void)? = nil,
        onToggleMute: ((ConversationPreview) -> Void)? = nil,
        onToggleRead: ((ConversationPreview) -> Void)? = nil
    ) {
        self.conversations = conversations
        self.selection = selection
        self.configuration = configuration
        self.onOpenConversation = onOpenConversation
        self.onDeleteConversation = onDeleteConversation
        self.onToggleMute = onToggleMute
        self.onToggleRead = onToggleRead
    }

    public var body: some View {
        Group {
            if conversations.isEmpty {
                ContentUnavailableView(
                    configuration.emptyStateTitle,
                    systemImage: "message",
                    description: configuration.emptyStateMessage.map(Text.init)
                )
            } else {
                listView
            }
        }
    }

    private var pinnedConversations: [ConversationPreview] {
        conversations.filter(\.isPinned)
    }

    private var regularConversations: [ConversationPreview] {
        conversations.filter { $0.isPinned == false }
    }

    private var listView: some View {
        let selectionBinding = selection ?? .constant(nil)
        return List(selection: selectionBinding) {
            if configuration.showsPinnedSection, pinnedConversations.isEmpty == false {
                PinnedConversationStripView(
                    conversations: pinnedConversations,
                    onOpenConversation: onOpenConversation
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }

            ForEach(regularConversations) { conversation in
                Button {
                    onOpenConversation(conversation)
                } label: {
                    ConversationRowView(conversation: conversation, configuration: configuration)
                }
                .buttonStyle(.plain)
                .tag(conversation.id)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if let onDeleteConversation {
                        Button(role: .destructive) {
                            onDeleteConversation(conversation)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                    if let onToggleMute {
                        Button {
                            onToggleMute(conversation)
                        } label: {
                            Label(
                                conversation.isMuted ? "Unmute" : "Mute",
                                systemImage: conversation.isMuted ? "bell" : "bell.slash"
                            )
                        }
                        .tint(.gray)
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if let onToggleRead {
                        Button {
                            onToggleRead(conversation)
                        } label: {
                            Label(
                                conversation.unreadCount > 0 ? "Mark Read" : "Mark Unread",
                                systemImage: conversation.unreadCount > 0 ? "envelope.open" : "envelope.badge"
                            )
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview("Conversation List Light") {
    NavigationStack {
        ConversationListScreen(
            conversations: ChatPreviewFixtures.listPreviews,
            onOpenConversation: { _ in }
        )
        .chatTheme(.messages)
        .navigationTitle("Messages")
    }
}

#Preview("Conversation List Dark") {
    NavigationStack {
        ConversationListScreen(
            conversations: ChatPreviewFixtures.listPreviews,
            onOpenConversation: { _ in }
        )
        .chatTheme(.messages)
        .navigationTitle("Messages")
    }
    .preferredColorScheme(.dark)
}

#Preview("Conversation List RTL") {
    NavigationStack {
        ConversationListScreen(
            conversations: ChatPreviewFixtures.listPreviews,
            onOpenConversation: { _ in }
        )
        .chatTheme(.messages)
    }
    .environment(\.layoutDirection, .rightToLeft)
}
