import SwiftUI

/// A high-level chat thread screen that composes the transcript and message composer.
public struct ChatThreadScreen: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.chatHeaderRenderer) private var headerRenderer

    /// The active conversation.
    public var conversation: ChatConversation

    /// Messages in the active thread.
    public var messages: [ChatMessage]

    /// Bound composer draft text.
    @Binding public var draftText: String

    /// Active typing participants.
    public var typingParticipants: [TypingParticipant]

    /// Thread configuration.
    public var configuration: ChatThreadConfiguration

    /// Send callback for text messages.
    public var onSendText: (String) -> Void

    /// Retry callback for failed messages.
    public var onRetryMessage: ((ChatMessage) -> Void)?

    /// Optional callback used to load older messages.
    public var onLoadEarlierMessages: (() async -> Void)?

    /// Creates a chat thread screen.
    public init(
        conversation: ChatConversation,
        messages: [ChatMessage],
        draftText: Binding<String>,
        typingParticipants: [TypingParticipant] = [],
        configuration: ChatThreadConfiguration = .messages,
        onSendText: @escaping (String) -> Void,
        onRetryMessage: ((ChatMessage) -> Void)? = nil,
        onLoadEarlierMessages: (() async -> Void)? = nil
    ) {
        self.conversation = conversation
        self.messages = messages
        self._draftText = draftText
        self.typingParticipants = typingParticipants
        self.configuration = configuration
        self.onSendText = onSendText
        self.onRetryMessage = onRetryMessage
        self.onLoadEarlierMessages = onLoadEarlierMessages
    }

    public var body: some View {
        ChatTranscriptView(
            conversation: conversation,
            messages: messages,
            typingParticipants: typingParticipants,
            configuration: configuration,
            onRetryMessage: onRetryMessage,
            onLoadEarlierMessages: onLoadEarlierMessages
        )
        .background(theme.colors.transcriptBackground)
        .navigationTitle(theme.formatters.conversationTitle(conversation))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            MessageComposerView(
                text: $draftText,
                configuration: configuration.composer,
                onSendText: onSendText
            )
        }
        .overlay(alignment: .top) {
            if let header = headerRenderer.render(conversation: conversation) {
                header
                    .padding(.top, 4)
            }
        }
    }
}

#Preview("Direct Thread") {
    struct DirectThreadPreview: View {
        @State private var draft = ""

        var body: some View {
            NavigationStack {
                ChatThreadScreen(
                    conversation: ChatPreviewFixtures.directConversation,
                    messages: ChatPreviewFixtures.directMessages,
                    draftText: $draft,
                    onSendText: { _ in }
                )
                .chatTheme(.messages)
            }
        }
    }

    return DirectThreadPreview()
}

#Preview("Group Thread") {
    struct GroupThreadPreview: View {
        @State private var draft = "On my way"

        var body: some View {
            NavigationStack {
                ChatThreadScreen(
                    conversation: ChatPreviewFixtures.groupConversation,
                    messages: ChatPreviewFixtures.groupMessages,
                    draftText: $draft,
                    typingParticipants: ChatPreviewFixtures.typingParticipants,
                    onSendText: { _ in },
                    onRetryMessage: { _ in }
                )
                .chatTheme(.messages)
            }
        }
    }

    return GroupThreadPreview()
}

#Preview("Accessibility Size") {
    struct AccessibleThreadPreview: View {
        @State private var draft = ""

        var body: some View {
            NavigationStack {
                ChatThreadScreen(
                    conversation: ChatPreviewFixtures.directConversation,
                    messages: ChatPreviewFixtures.directMessages,
                    draftText: $draft,
                    onSendText: { _ in }
                )
                .chatTheme(.messages)
            }
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }

    return AccessibleThreadPreview()
}
