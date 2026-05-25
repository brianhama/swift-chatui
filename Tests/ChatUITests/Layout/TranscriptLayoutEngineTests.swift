import CoreGraphics
import XCTest
@testable import ChatUI

final class TranscriptLayoutEngineTests: XCTestCase {
    func testGroupsMessagesBySenderAndThreshold() {
        var engine = TranscriptLayoutEngine()
        engine.calendar = FixtureFactory.calendar
        let conversation = FixtureFactory.groupConversation()
        let messages = [
            FixtureFactory.message(
                id: "1",
                senderID: FixtureFactory.sam.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 0),
                text: "First"
            ),
            FixtureFactory.message(
                id: "2",
                senderID: FixtureFactory.sam.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 3),
                text: "Second"
            ),
            FixtureFactory.message(
                id: "3",
                senderID: FixtureFactory.sam.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 10),
                text: "Third"
            )
        ]

        let items = engine.makeItems(
            conversation: conversation,
            messages: messages,
            configuration: .messages
        )

        let contexts = items.compactMap { item -> MessageRowContext? in
            guard case let .message(messageItem) = item else { return nil }
            return messageItem.context
        }

        XCTAssertEqual(contexts.map(\.groupPosition), [.first, .last, .single])
        XCTAssertEqual(contexts.map(\.showsSenderName), [true, false, true])
    }

    func testStableSortPreservesInputOrderForMatchingTimestamps() {
        var engine = TranscriptLayoutEngine()
        engine.calendar = FixtureFactory.calendar
        let direct = FixtureFactory.directConversation()
        let sharedTime = FixtureFactory.date(2026, 4, 10, 12, 0)

        let unordered = [
            FixtureFactory.message(id: "a", senderID: FixtureFactory.sam.id, timestamp: sharedTime, text: "A", conversationID: direct.id),
            FixtureFactory.message(id: "b", senderID: FixtureFactory.sam.id, timestamp: sharedTime, text: "B", conversationID: direct.id),
            FixtureFactory.message(id: "c", senderID: FixtureFactory.me.id, timestamp: sharedTime, text: "C", conversationID: direct.id)
        ]

        let ordered = engine.stableSort(unordered)
        XCTAssertEqual(ordered.map(\.id), ["a", "b", "c"])
    }

    func testGroupChatsOnlyShowAvatarsOnIncomingSingleOrLastRows() {
        var engine = TranscriptLayoutEngine()
        engine.calendar = FixtureFactory.calendar
        let conversation = FixtureFactory.groupConversation()
        let messages = [
            FixtureFactory.message(id: "1", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 10, 0), text: "One"),
            FixtureFactory.message(id: "2", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 10, 1), text: "Two"),
            FixtureFactory.message(id: "3", senderID: FixtureFactory.me.id, timestamp: FixtureFactory.date(2026, 4, 10, 10, 2), text: "Three")
        ]

        let items = engine.makeItems(conversation: conversation, messages: messages, configuration: .messages)
        let contexts = items.compactMap { item -> MessageRowContext? in
            guard case let .message(messageItem) = item else { return nil }
            return messageItem.context
        }

        XCTAssertEqual(contexts.map(\.showsAvatar), [false, true, false])
    }

    func testUsesProvidedMetricsForMessageSpacing() {
        var engine = TranscriptLayoutEngine()
        engine.calendar = FixtureFactory.calendar
        let conversation = FixtureFactory.groupConversation()
        let messages = [
            FixtureFactory.message(id: "1", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 10, 0), text: "One"),
            FixtureFactory.message(id: "2", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 10, 1), text: "Two"),
            FixtureFactory.message(id: "3", senderID: FixtureFactory.me.id, timestamp: FixtureFactory.date(2026, 4, 10, 10, 2), text: "Three")
        ]
        var metrics = ChatMetrics.messages
        metrics.messageRunSpacing = 1
        metrics.messageGroupSpacing = 4

        let items = engine.makeItems(
            conversation: conversation,
            messages: messages,
            configuration: .messages,
            metrics: metrics
        )
        let topSpacings = items.compactMap { item -> CGFloat? in
            guard case let .message(messageItem) = item else { return nil }
            return messageItem.topSpacing
        }

        XCTAssertEqual(topSpacings, [0, 1, 4])
    }
}
