import Foundation
@testable import ChatUI

enum FixtureFactory {
    static let timeZone = TimeZone(secondsFromGMT: 0)!

    static var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(
            timeZone: timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }

    static let me = ChatParticipant(id: "me", displayName: "Alex", initials: "AL", accentColorToken: "blue")
    static let sam = ChatParticipant(id: "sam", displayName: "Sam", initials: "SA", accentColorToken: "green")
    static let taylor = ChatParticipant(id: "taylor", displayName: "Taylor", initials: "TA", accentColorToken: "orange")
    static let jordan = ChatParticipant(id: "jordan", displayName: "Jordan", initials: "JO", accentColorToken: "purple")

    static func directConversation() -> ChatConversation {
        ChatConversation(
            id: "direct",
            kind: .direct,
            participants: [me, sam],
            currentUserID: me.id
        )
    }

    static func groupConversation() -> ChatConversation {
        ChatConversation(
            id: "group",
            kind: .group,
            participants: [me, sam, taylor, jordan],
            currentUserID: me.id
        )
    }

    static func message(
        id: String,
        senderID: String,
        timestamp: Date,
        text: String,
        conversationID: String = "group",
        status: MessageStatus = .sent,
        reactions: [MessageReaction] = [],
        isEdited: Bool = false
    ) -> ChatMessage {
        ChatMessage(
            id: id,
            conversationID: conversationID,
            senderID: senderID,
            timestamp: timestamp,
            content: .text(text),
            status: status,
            reactions: reactions,
            isEdited: isEdited
        )
    }
}
