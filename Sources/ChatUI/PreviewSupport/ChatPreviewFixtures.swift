import Foundation

enum ChatPreviewFixtures {
    static let me = ChatParticipant(id: "me", displayName: "Alex", shortDisplayName: "Alex", initials: "AL", accentColorToken: "me")
    static let sam = ChatParticipant(id: "sam", displayName: "Sam Rivera", shortDisplayName: "Sam", initials: "SR", accentColorToken: "sam")
    static let taylor = ChatParticipant(id: "taylor", displayName: "Taylor Brooks", shortDisplayName: "Taylor", initials: "TB", accentColorToken: "taylor")
    static let jordan = ChatParticipant(id: "jordan", displayName: "Jordan Kim", shortDisplayName: "Jordan", initials: "JK", accentColorToken: "jordan")

    static let now = Date(timeIntervalSinceReferenceDate: 765_432_100)

    static let directConversation = ChatConversation(
        id: "direct",
        kind: .direct,
        participants: [me, sam],
        currentUserID: me.id
    )

    static let groupConversation = ChatConversation(
        id: "group",
        kind: .group,
        explicitTitle: nil,
        participants: [me, sam, taylor, jordan],
        currentUserID: me.id
    )

    static let longText = """
    This is a deliberately long message preview used to verify wrapping, bubble width, and dynamic type behavior across the transcript and row components.
    """

    static let directMessages: [ChatMessage] = [
        ChatMessage(id: "m1", conversationID: directConversation.id, senderID: sam.id, timestamp: now.addingTimeInterval(-7_200), content: .text("Are you still on for lunch?")),
        ChatMessage(id: "m2", conversationID: directConversation.id, senderID: me.id, timestamp: now.addingTimeInterval(-7_050), content: .text("Yep, I can be there around 12:15."), status: .read(at: now.addingTimeInterval(-7_000))),
        ChatMessage(id: "m3", conversationID: directConversation.id, senderID: sam.id, timestamp: now.addingTimeInterval(-6_990), content: .text(longText)),
        ChatMessage(id: "m4", conversationID: directConversation.id, senderID: me.id, timestamp: now.addingTimeInterval(-60), content: .text("Perfect."), status: .delivered, reactions: [
            MessageReaction(id: "r1", emoji: "👍", senderID: sam.id),
            MessageReaction(id: "r2", emoji: "👍", senderID: sam.id)
        ])
    ]

    static let groupMessages: [ChatMessage] = [
        ChatMessage(id: "g1", conversationID: groupConversation.id, senderID: sam.id, timestamp: now.addingTimeInterval(-86_400), content: .text("Morning team")),
        ChatMessage(id: "g2", conversationID: groupConversation.id, senderID: taylor.id, timestamp: now.addingTimeInterval(-86_100), content: .text("I added the latest mocks.")),
        ChatMessage(id: "g3", conversationID: groupConversation.id, senderID: taylor.id, timestamp: now.addingTimeInterval(-86_010), content: .text("Let me know if you want the spacing tightened.")),
        ChatMessage(id: "g4", conversationID: groupConversation.id, senderID: me.id, timestamp: now.addingTimeInterval(-85_800), content: .text("Looks good to me"), status: .sent),
        ChatMessage(id: "g5", conversationID: groupConversation.id, senderID: jordan.id, timestamp: now.addingTimeInterval(-1_200), content: .text("I’ll test the build after standup.")),
        ChatMessage(id: "g6", conversationID: groupConversation.id, senderID: me.id, timestamp: now.addingTimeInterval(-400), content: .text("Shipping the package preview now."), status: .sending),
        failedMessage
    ]

    static let failedMessage = ChatMessage(
        id: "g7",
        conversationID: groupConversation.id,
        senderID: me.id,
        timestamp: now.addingTimeInterval(-120),
        content: .text("Network tunnel dropped again."),
        status: .failed(reason: "Offline")
    )

    static let emojiMessage = ChatMessage(
        id: "emoji",
        conversationID: directConversation.id,
        senderID: sam.id,
        timestamp: now,
        content: .text("🎉🔥🙌")
    )

    static let typingParticipants = [
        TypingParticipant(id: "typing-sam", participantID: sam.id, startedAt: now)
    ]

    static let listPreviews: [ConversationPreview] = [
        ConversationPreview(
            id: groupConversation.id,
            participants: groupConversation.participants,
            explicitTitle: nil,
            latestMessagePreview: "Shipping the package preview now.",
            latestActivityAt: now.addingTimeInterval(-120),
            unreadCount: 3,
            isMuted: false,
            isPinned: true,
            draftPreview: nil,
            kind: .group,
            currentUserID: me.id
        ),
        ConversationPreview(
            id: directConversation.id,
            participants: directConversation.participants,
            explicitTitle: nil,
            latestMessagePreview: longText,
            latestActivityAt: now.addingTimeInterval(-60),
            unreadCount: 0,
            isMuted: true,
            isPinned: true,
            draftPreview: "Need to confirm lunch time",
            kind: .direct,
            currentUserID: me.id
        ),
        ConversationPreview(
            id: "long",
            participants: [me, jordan],
            explicitTitle: "Long Transcript",
            latestMessagePreview: "Loaded 50 more messages",
            latestActivityAt: now.addingTimeInterval(-3_600),
            unreadCount: 1,
            isMuted: false,
            isPinned: false,
            draftPreview: nil,
            kind: .direct,
            currentUserID: me.id
        )
    ]
}
