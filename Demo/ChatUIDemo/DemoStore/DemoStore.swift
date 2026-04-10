import ChatUI
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class DemoStore {
    var conversationsByID: [ChatConversation.ID: ChatConversation]
    var messagesByConversationID: [ChatConversation.ID: [ChatMessage]]
    var previews: [ConversationPreview]
    var typingParticipantsByConversationID: [ChatConversation.ID: [TypingParticipant]]
    var olderMessageBatches: [ChatConversation.ID: [[ChatMessage]]]
    var drafts: [ChatConversation.ID: String]
    var selectedConversationID: ChatConversation.ID?
    var searchText = ""

    private let currentUserID = "me"
    private let now = Date()

    init() {
        let seed = DemoSeed.make()
        self.conversationsByID = seed.conversations
        self.messagesByConversationID = seed.messages
        self.previews = seed.previews
        self.typingParticipantsByConversationID = seed.typingParticipants
        self.olderMessageBatches = seed.olderMessageBatches
        self.drafts = seed.drafts
        self.selectedConversationID = seed.previews.first?.id
        refreshPreviews()
    }

    var filteredPreviews: [ConversationPreview] {
        guard searchText.isEmpty == false else {
            return previews
        }

        let needle = searchText.localizedLowercase
        return previews.filter { preview in
            preview.latestMessagePreview.localizedLowercase.contains(needle) ||
                (preview.explicitTitle?.localizedLowercase.contains(needle) ?? false) ||
                preview.participants.contains(where: { $0.displayName.localizedLowercase.contains(needle) })
        }
    }

    var activeConversation: ChatConversation? {
        guard let selectedConversationID else {
            return previews.first.flatMap { conversationsByID[$0.id] }
        }
        return conversationsByID[selectedConversationID]
    }

    var activeMessages: [ChatMessage] {
        guard let conversationID = activeConversation?.id else {
            return []
        }
        return messagesByConversationID[conversationID, default: []]
    }

    var activeTypingParticipants: [TypingParticipant] {
        guard let conversationID = activeConversation?.id else {
            return []
        }
        return typingParticipantsByConversationID[conversationID, default: []]
    }

    func openConversation(_ preview: ConversationPreview) {
        selectedConversationID = preview.id
        markConversationAsRead(preview.id)
    }

    func deleteConversation(_ preview: ConversationPreview) {
        conversationsByID.removeValue(forKey: preview.id)
        messagesByConversationID.removeValue(forKey: preview.id)
        typingParticipantsByConversationID.removeValue(forKey: preview.id)
        olderMessageBatches.removeValue(forKey: preview.id)
        drafts.removeValue(forKey: preview.id)
        previews.removeAll { $0.id == preview.id }
        if selectedConversationID == preview.id {
            selectedConversationID = previews.first?.id
        }
    }

    func toggleMute(_ preview: ConversationPreview) {
        mutatePreview(preview.id) { item in
            item.isMuted.toggle()
        }
    }

    func toggleRead(_ preview: ConversationPreview) {
        mutatePreview(preview.id) { item in
            item.unreadCount = item.unreadCount > 0 ? 0 : 1
        }
    }

    func draftBinding() -> Binding<String> {
        Binding(
            get: {
                guard let conversationID = self.activeConversation?.id else { return "" }
                return self.drafts[conversationID, default: ""]
            },
            set: { newValue in
                guard let conversationID = self.activeConversation?.id else { return }
                self.drafts[conversationID] = newValue
                self.refreshPreviews()
            }
        )
    }

    func send(_ text: String) {
        guard let conversation = activeConversation else {
            return
        }

        let conversationID = conversation.id
        let messageID = UUID().uuidString
        let shouldFail = text.localizedCaseInsensitiveContains("fail")
        let message = ChatMessage(
            id: messageID,
            conversationID: conversationID,
            senderID: currentUserID,
            timestamp: Date(),
            content: .text(text),
            status: .sending
        )

        messagesByConversationID[conversationID, default: []].append(message)
        drafts[conversationID] = ""
        refreshPreviews()

        Task {
            try? await Task.sleep(for: .seconds(0.9))
            if shouldFail {
                updateStatus(for: messageID, in: conversationID, status: .failed(reason: "Timed out"))
                return
            }

            updateStatus(for: messageID, in: conversationID, status: .sent)
            try? await Task.sleep(for: .seconds(1.2))
            updateStatus(for: messageID, in: conversationID, status: .delivered)
            try? await Task.sleep(for: .seconds(1.2))
            updateStatus(for: messageID, in: conversationID, status: .read(at: Date()))
        }
    }

    func retry(_ message: ChatMessage) {
        updateStatus(for: message.id, in: message.conversationID, status: .sending)
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            updateStatus(for: message.id, in: message.conversationID, status: .sent)
            try? await Task.sleep(for: .seconds(0.9))
            updateStatus(for: message.id, in: message.conversationID, status: .delivered)
        }
    }

    func loadEarlierMessages() async {
        guard let conversationID = activeConversation?.id else {
            return
        }

        guard var batches = olderMessageBatches[conversationID], batches.isEmpty == false else {
            return
        }

        let nextBatch = batches.removeFirst()
        olderMessageBatches[conversationID] = batches
        try? await Task.sleep(for: .seconds(0.5))
        messagesByConversationID[conversationID, default: []] = nextBatch + messagesByConversationID[conversationID, default: []]
        refreshPreviews()
    }

    private func updateStatus(for messageID: String, in conversationID: String, status: MessageStatus) {
        guard var messages = messagesByConversationID[conversationID],
              let index = messages.firstIndex(where: { $0.id == messageID }) else {
            return
        }

        messages[index].status = status
        messagesByConversationID[conversationID] = messages
        refreshPreviews()
    }

    private func markConversationAsRead(_ conversationID: String) {
        mutatePreview(conversationID) { preview in
            preview.unreadCount = 0
        }
    }

    private func mutatePreview(_ id: String, update: (inout ConversationPreview) -> Void) {
        guard let index = previews.firstIndex(where: { $0.id == id }) else {
            return
        }

        update(&previews[index])
    }

    private func refreshPreviews() {
        previews = previews.compactMap { preview in
            guard let conversation = conversationsByID[preview.id] else {
                return nil
            }

            let messages = messagesByConversationID[preview.id, default: []]
            let latestMessage = messages.last
            let latestPreview = latestMessage.map(summary(for:)) ?? preview.latestMessagePreview
            let latestDate = latestMessage?.timestamp ?? preview.latestActivityAt
            let draft = drafts[preview.id]

            return ConversationPreview(
                id: preview.id,
                participants: conversation.participants,
                explicitTitle: conversation.explicitTitle,
                latestMessagePreview: latestPreview,
                latestActivityAt: latestDate,
                unreadCount: selectedConversationID == preview.id ? 0 : preview.unreadCount,
                isMuted: preview.isMuted,
                isPinned: preview.isPinned,
                draftPreview: draft?.isEmpty == false ? draft : nil,
                kind: conversation.kind,
                currentUserID: conversation.currentUserID
            )
        }
        .sorted { lhs, rhs in
            if lhs.isPinned == rhs.isPinned {
                return lhs.latestActivityAt > rhs.latestActivityAt
            }
            return lhs.isPinned && rhs.isPinned == false
        }
    }

    private func summary(for message: ChatMessage) -> String {
        switch message.content {
        case let .text(text):
            return text
        case .image:
            return "Image"
        case .video:
            return "Video"
        case .audio:
            return "Audio"
        case let .custom(_, summary):
            return summary ?? "Attachment"
        }
    }
}

private enum DemoSeed {
    struct Result {
        let conversations: [ChatConversation.ID: ChatConversation]
        let messages: [ChatConversation.ID: [ChatMessage]]
        let previews: [ConversationPreview]
        let typingParticipants: [ChatConversation.ID: [TypingParticipant]]
        let olderMessageBatches: [ChatConversation.ID: [[ChatMessage]]]
        let drafts: [ChatConversation.ID: String]
    }

    static func make() -> Result {
        let me = ChatParticipant(id: "me", displayName: "Alex", initials: "AL", accentColorToken: "alex")
        let sam = ChatParticipant(id: "sam", displayName: "Sam Rivera", initials: "SR", accentColorToken: "sam")
        let taylor = ChatParticipant(id: "taylor", displayName: "Taylor Brooks", initials: "TB", accentColorToken: "tay")
        let jordan = ChatParticipant(id: "jordan", displayName: "Jordan Kim", initials: "JK", accentColorToken: "jor")
        let mika = ChatParticipant(id: "mika", displayName: "Mikaela Sun-Carter", initials: "MS", accentColorToken: "mik")

        let direct = ChatConversation(id: "direct", kind: .direct, participants: [me, sam], currentUserID: me.id)
        let group = ChatConversation(id: "group", kind: .group, participants: [me, sam, taylor, jordan], currentUserID: me.id)
        let long = ChatConversation(id: "long", kind: .direct, explicitTitle: "Long Transcript", participants: [me, jordan], currentUserID: me.id)
        let names = ChatConversation(id: "names", kind: .group, explicitTitle: nil, participants: [me, mika, sam], currentUserID: me.id)

        let base = Date(timeIntervalSinceReferenceDate: 765_432_100)
        func textMessage(_ id: String, _ conversation: ChatConversation, _ senderID: String, _ offset: TimeInterval, _ text: String, status: MessageStatus = .sent, reactions: [MessageReaction] = []) -> ChatMessage {
            ChatMessage(
                id: id,
                conversationID: conversation.id,
                senderID: senderID,
                timestamp: base.addingTimeInterval(offset),
                content: .text(text),
                status: status,
                reactions: reactions
            )
        }

        let directMessages = [
            textMessage("d1", direct, sam.id, -8_000, "Lunch at 12:15?"),
            textMessage("d2", direct, me.id, -7_950, "Yep, I’m in.", status: .read(at: base.addingTimeInterval(-7_900))),
            textMessage("d3", direct, sam.id, -7_860, "Perfect."),
            textMessage("d4", direct, sam.id, -7_850, "🎉🔥🙌"),
            textMessage("d5", direct, me.id, -400, "I’ll head out in five.", status: .delivered, reactions: [
                MessageReaction(id: "r1", emoji: "👍", senderID: sam.id)
            ])
        ]

        let groupMessages = [
            textMessage("g1", group, sam.id, -90_000, "Morning team"),
            textMessage("g2", group, taylor.id, -89_820, "I uploaded the new bubble spacing pass."),
            textMessage("g3", group, taylor.id, -89_760, "It should feel closer to Messages."),
            textMessage("g4", group, me.id, -89_100, "Reviewing now.", status: .sent),
            textMessage("g5", group, jordan.id, -3_600, "I’ll run the simulator check next."),
            textMessage("g6", group, me.id, -1_200, "If the build fails, I’ll patch it.", status: .sending),
            textMessage("g7", group, me.id, -600, "This one will fail on purpose.", status: .failed(reason: "Offline"))
        ]

        let longMessages = (0..<24).map { index in
            let sender = index.isMultiple(of: 3) ? me.id : jordan.id
            return textMessage(
                "l\(index)",
                long,
                sender,
                TimeInterval(-index * 240),
                index.isMultiple(of: 5) ? "Loaded message \(index). This transcript exists to prove scrolling, grouping, and earlier-message loading." : "Loaded message \(index)"
            )
        }
        .sorted { $0.timestamp < $1.timestamp }

        let olderLongBatchOne = (24..<36).map { index in
            textMessage("ol\(index)", long, index.isMultiple(of: 2) ? jordan.id : me.id, TimeInterval(-(index + 6) * 240), "Older message \(index)")
        }
        .sorted { $0.timestamp < $1.timestamp }

        let olderLongBatchTwo = (36..<48).map { index in
            textMessage("ool\(index)", long, index.isMultiple(of: 2) ? jordan.id : me.id, TimeInterval(-(index + 10) * 240), "Archive message \(index)")
        }
        .sorted { $0.timestamp < $1.timestamp }

        let longNameMessages = [
            textMessage("n1", names, mika.id, -10_000, "The accessibility pass still looks good at extra-extra-large text sizes."),
            textMessage("n2", names, me.id, -9_980, "Great. I also tested a very long reply so the composer and transcript wrap cleanly across dynamic type without clipping.", status: .read(at: base.addingTimeInterval(-9_900)))
        ]

        let previews = [
            ConversationPreview(
                id: group.id,
                participants: group.participants,
                explicitTitle: nil,
                latestMessagePreview: "This one will fail on purpose.",
                latestActivityAt: groupMessages.last?.timestamp ?? base,
                unreadCount: 3,
                isMuted: false,
                isPinned: true,
                draftPreview: nil,
                kind: .group,
                currentUserID: me.id
            ),
            ConversationPreview(
                id: direct.id,
                participants: direct.participants,
                explicitTitle: nil,
                latestMessagePreview: "I’ll head out in five.",
                latestActivityAt: directMessages.last?.timestamp ?? base,
                unreadCount: 0,
                isMuted: true,
                isPinned: true,
                draftPreview: "Need to confirm the restaurant",
                kind: .direct,
                currentUserID: me.id
            ),
            ConversationPreview(
                id: long.id,
                participants: long.participants,
                explicitTitle: long.explicitTitle,
                latestMessagePreview: "Loaded message 23",
                latestActivityAt: longMessages.last?.timestamp ?? base,
                unreadCount: 1,
                isMuted: false,
                isPinned: false,
                draftPreview: nil,
                kind: .direct,
                currentUserID: me.id
            ),
            ConversationPreview(
                id: names.id,
                participants: names.participants,
                explicitTitle: names.explicitTitle,
                latestMessagePreview: "The accessibility pass still looks good.",
                latestActivityAt: longNameMessages.last?.timestamp ?? base,
                unreadCount: 0,
                isMuted: false,
                isPinned: false,
                draftPreview: nil,
                kind: .group,
                currentUserID: me.id
            )
        ]

        return Result(
            conversations: [
                direct.id: direct,
                group.id: group,
                long.id: long,
                names.id: names
            ],
            messages: [
                direct.id: directMessages,
                group.id: groupMessages,
                long.id: longMessages,
                names.id: longNameMessages
            ],
            previews: previews,
            typingParticipants: [
                group.id: [TypingParticipant(id: "typing-1", participantID: sam.id, startedAt: base)]
            ],
            olderMessageBatches: [
                long.id: [olderLongBatchOne, olderLongBatchTwo]
            ],
            drafts: [
                direct.id: "Need to confirm the restaurant"
            ]
        )
    }
}
