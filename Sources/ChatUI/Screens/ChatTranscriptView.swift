import SwiftUI
import UIKit

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
    @State private var transcriptTopSpacerHeight: CGFloat = 0
    @State private var isLoadingEarlier = false
    @State private var prependAnchorID: TranscriptDisplayItem.ID?
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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: transcriptTopSpacerHeight)

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
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding(.horizontal, theme.metrics.transcriptHorizontalPadding)
                .padding(.vertical, 8)
                .background(
                    ScrollViewMetricsProbe { metrics in
                        updateScrollMetrics(metrics)
                    }
                    .allowsHitTesting(false)
                )
            }
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

    private func updateScrollMetrics(_ metrics: ScrollViewMetrics) {
        bottomDistance = metrics.bottomDistance

        let contentHeightWithoutSpacer = max(0, metrics.contentHeight - transcriptTopSpacerHeight)
        let nextTopSpacerHeight = max(0, metrics.viewportHeight - contentHeightWithoutSpacer)

        guard abs(transcriptTopSpacerHeight - nextTopSpacerHeight) > 0.5 else {
            return
        }

        transcriptTopSpacerHeight = nextTopSpacerHeight
    }

    private var displayItems: [TranscriptDisplayItem] {
        engine.makeItems(
            conversation: conversation,
            messages: messages,
            configuration: configuration,
            metrics: theme.metrics
        )
    }

    private var firstMessageDisplayID: TranscriptDisplayItem.ID? {
        displayItems.first { item in
            guard case .message = item else {
                return false
            }
            return true
        }?.id
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
        prependAnchorID = firstMessageDisplayID
        await onLoadEarlierMessages()
        isLoadingEarlier = false
    }
}

private struct ScrollViewMetrics: Equatable {
    var viewportHeight: CGFloat
    var contentHeight: CGFloat
    var bottomDistance: CGFloat

    func isMeaningfullyDifferent(from other: ScrollViewMetrics) -> Bool {
        abs(viewportHeight - other.viewportHeight) > 0.5
            || abs(contentHeight - other.contentHeight) > 0.5
            || abs(bottomDistance - other.bottomDistance) > 0.5
    }
}

private struct ScrollViewMetricsProbe: UIViewRepresentable {
    var onChange: (ScrollViewMetrics) -> Void

    func makeUIView(context: Context) -> ScrollViewMetricsView {
        let view = ScrollViewMetricsView()
        view.onChange = onChange
        return view
    }

    func updateUIView(_ uiView: ScrollViewMetricsView, context: Context) {
        uiView.onChange = onChange
        DispatchQueue.main.async { [weak uiView] in
            uiView?.attachToNearestScrollView()
        }
    }
}

private final class ScrollViewMetricsView: UIView {
    var onChange: (ScrollViewMetrics) -> Void = { _ in }

    private weak var scrollView: UIScrollView?
    private var observations: [NSKeyValueObservation] = []
    private var lastReportedMetrics: ScrollViewMetrics?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.async { [weak self] in
            self?.attachToNearestScrollView()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        DispatchQueue.main.async { [weak self] in
            self?.attachToNearestScrollView()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attachToNearestScrollView()
        reportScrollMetrics()
    }

    func attachToNearestScrollView() {
        guard let scrollView = nearestScrollView() else {
            return
        }

        guard self.scrollView !== scrollView else {
            reportScrollMetrics()
            return
        }

        self.scrollView = scrollView
        observations = [
            scrollView.observe(\.contentOffset, options: [.initial, .new]) { [weak self] _, _ in
                self?.reportScrollMetrics()
            },
            scrollView.observe(\.contentSize, options: [.initial, .new]) { [weak self] _, _ in
                self?.reportScrollMetrics()
            },
            scrollView.observe(\.bounds, options: [.initial, .new]) { [weak self] _, _ in
                self?.reportScrollMetrics()
            },
            scrollView.observe(\.contentInset, options: [.initial, .new]) { [weak self] _, _ in
                self?.reportScrollMetrics()
            }
        ]

        reportScrollMetrics()
    }

    private func nearestScrollView() -> UIScrollView? {
        var view = superview

        while let currentView = view {
            if let scrollView = currentView as? UIScrollView {
                return scrollView
            }

            view = currentView.superview
        }

        return nil
    }

    private func reportScrollMetrics() {
        guard let scrollView else {
            return
        }

        let viewportHeight = max(
            0,
            scrollView.bounds.height
                - scrollView.adjustedContentInset.top
                - scrollView.adjustedContentInset.bottom
        )
        let visibleBottom = scrollView.contentOffset.y
            + scrollView.bounds.height
            - scrollView.adjustedContentInset.bottom
        let metrics = ScrollViewMetrics(
            viewportHeight: viewportHeight,
            contentHeight: scrollView.contentSize.height,
            bottomDistance: max(0, scrollView.contentSize.height - visibleBottom)
        )

        guard lastReportedMetrics.map({ metrics.isMeaningfullyDifferent(from: $0) }) ?? true else {
            return
        }

        lastReportedMetrics = metrics
        DispatchQueue.main.async { [weak self] in
            self?.onChange(metrics)
        }
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
