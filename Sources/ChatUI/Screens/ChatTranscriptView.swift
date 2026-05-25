import SwiftUI

/// A scrollable transcript view that renders separators, grouped message rows, typing state, and jump-to-latest affordances.
public struct ChatTranscriptView: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.chatTypingIndicatorRenderer) private var typingIndicatorRenderer

    /// The owning conversation metadata.
    public var conversation: ChatConversation

    /// Messages to render in the transcript.
    public var messages: [ChatMessage]

    /// Active typing participants.
    public var typingParticipants: [TypingParticipant]

    /// Thread configuration.
    public var configuration: ChatThreadConfiguration

    /// Optional retry action for failed messages.
    public var onRetryMessage: ((ChatMessage) -> Void)?

    /// Optional callback used to request older messages.
    public var onLoadEarlierMessages: (() async -> Void)?

    @State private var hasPerformedInitialScroll = false
    @State private var bottomDistance: CGFloat = 0
    @State private var isLoadingEarlier = false
    @State private var prependAnchorID: String?
    @State private var previousMessageIDs: [String] = []

    private let engine = TranscriptLayoutEngine()
    private let bottomAnchorID = "chat-bottom-anchor"

    /// Creates a chat transcript view.
    public init(
        conversation: ChatConversation,
        messages: [ChatMessage],
        typingParticipants: [TypingParticipant] = [],
        configuration: ChatThreadConfiguration = .messages,
        onRetryMessage: ((ChatMessage) -> Void)? = nil,
        onLoadEarlierMessages: (() async -> Void)? = nil
    ) {
        self.conversation = conversation
        self.messages = messages
        self.typingParticipants = typingParticipants
        self.configuration = configuration
        self.onRetryMessage = onRetryMessage
        self.onLoadEarlierMessages = onLoadEarlierMessages
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Color.clear
                            .frame(height: 1)
                            .id("load-older-anchor")
                            .onAppear {
                                Task { await loadEarlierMessagesIfNeeded() }
                            }

                        ForEach(displayItems) { item in
                            switch item {
                            case let .dateSeparator(separator):
                                DateSeparatorView(
                                    title: theme.formatters.dateSeparator(separator.date, Date())
                                )
                                .padding(.top, theme.metrics.dateSeparatorTopSpacing)
                                .padding(.bottom, theme.metrics.dateSeparatorBottomSpacing)
                            case let .message(messageItem):
                                MessageRowView(
                                    conversation: conversation,
                                    message: messageItem.message,
                                    context: messageItem.context,
                                    configuration: configuration,
                                    onRetryMessage: onRetryMessage
                                )
                                .padding(.top, messageItem.topSpacing)
                            }
                        }

                        if typingParticipants.isEmpty == false {
                            typingIndicator
                                .padding(.top, theme.metrics.messageGroupSpacing)
                                .padding(.leading, theme.metrics.transcriptHorizontalPadding)
                        }

                        Color.clear
                            .frame(height: 1)
                            .id(bottomAnchorID)
                            .background(
                                GeometryReader { marker in
                                    Color.clear.preference(
                                        key: BottomAnchorPreferenceKey.self,
                                        value: marker.frame(in: .named("chat-transcript-scroll")).maxY
                                    )
                                }
                            )
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: max(0, geometry.size.height - 16),
                        alignment: .bottom
                    )
                    .padding(.horizontal, theme.metrics.transcriptHorizontalPadding)
                    .padding(.vertical, 8)
                }
                .coordinateSpace(name: "chat-transcript-scroll")
                .scrollDismissesKeyboard(.interactively)
                .background(theme.colors.transcriptBackground)
                .overlay(alignment: .bottomTrailing) {
                    if configuration.showsJumpToLatest, bottomDistance > configuration.jumpToLatestThreshold {
                        Button {
                            withAnimation(theme.animations.standard) {
                                proxy.scrollTo(bottomAnchorID, anchor: .bottom)
                            }
                        } label: {
                            Image(systemName: "arrow.down")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(theme.colors.incomingText)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 14)
                    }
                }
                .onPreferenceChange(BottomAnchorPreferenceKey.self) { bottomMarker in
                    bottomDistance = max(0, bottomMarker - geometry.size.height)
                }
                .onAppear {
                    guard hasPerformedInitialScroll == false else { return }
                    hasPerformedInitialScroll = true
                    previousMessageIDs = messages.map(\.id)
                    DispatchQueue.main.async {
                        proxy.scrollTo(bottomAnchorID, anchor: .bottom)
                    }
                }
                .onChange(of: messages.map(\.id)) { _, newIDs in
                    handleMessageChange(newIDs: newIDs, proxy: proxy)
                }
            }
        }
    }

    private var displayItems: [TranscriptDisplayItem] {
        engine.makeItems(
            conversation: conversation,
            messages: messages,
            configuration: configuration,
            metrics: theme.metrics
        )
    }

    @ViewBuilder
    private var typingIndicator: some View {
        if let customIndicator = typingIndicatorRenderer.render(
            typingParticipants: typingParticipants,
            participants: conversation.participants
        ) {
            customIndicator
        } else {
            TypingIndicatorView(
                typingParticipants: typingParticipants,
                participants: conversation.participants
            )
        }
    }

    private func handleMessageChange(newIDs: [String], proxy: ScrollViewProxy) {
        let oldIDs = previousMessageIDs
        defer { previousMessageIDs = newIDs }

        guard newIDs != oldIDs else {
            return
        }

        if let prependAnchorID, oldIDs.first != nil, newIDs.first != oldIDs.first {
            DispatchQueue.main.async {
                proxy.scrollTo(prependAnchorID, anchor: .top)
            }
            self.prependAnchorID = nil
            return
        }

        guard let latestMessage = messages.last else {
            return
        }

        if latestMessage.senderID == conversation.currentUserID || bottomDistance <= configuration.jumpToLatestThreshold {
            DispatchQueue.main.async {
                withAnimation(theme.animations.standard) {
                    proxy.scrollTo(bottomAnchorID, anchor: .bottom)
                }
            }
        }
    }

    private func loadEarlierMessagesIfNeeded() async {
        guard hasPerformedInitialScroll, isLoadingEarlier == false, let onLoadEarlierMessages else {
            return
        }

        isLoadingEarlier = true
        prependAnchorID = messages.first?.id
        await onLoadEarlierMessages()
        isLoadingEarlier = false
    }
}

private struct BottomAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview("Transcript") {
    ChatTranscriptView(
        conversation: ChatPreviewFixtures.groupConversation,
        messages: ChatPreviewFixtures.groupMessages,
        typingParticipants: ChatPreviewFixtures.typingParticipants,
        onRetryMessage: { _ in }
    )
    .chatTheme(.messages)
}
