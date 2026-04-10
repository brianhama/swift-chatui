import XCTest
@testable import ChatUI

final class DateSeparatorStrategyTests: XCTestCase {
    func testDayChangeSeparatorsAppear() {
        var engine = TranscriptLayoutEngine()
        engine.calendar = FixtureFactory.calendar
        let conversation = FixtureFactory.directConversation()
        let messages = [
            FixtureFactory.message(id: "1", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 9, 23, 59), text: "Late", conversationID: conversation.id),
            FixtureFactory.message(id: "2", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 0, 1), text: "Early", conversationID: conversation.id)
        ]

        let items = engine.makeItems(conversation: conversation, messages: messages, configuration: .messages)
        let separators = items.compactMap { item -> TranscriptDateSeparatorItem? in
            guard case let .dateSeparator(separator) = item else { return nil }
            return separator
        }

        XCTAssertEqual(separators.count, 2)
        XCTAssertTrue(engine.calendar.isDate(separators[0].date, inSameDayAs: messages[0].timestamp))
        XCTAssertTrue(engine.calendar.isDate(separators[1].date, inSameDayAs: messages[1].timestamp))
    }

    func testLargeGapSeparatorsAreOptional() {
        var engine = TranscriptLayoutEngine()
        engine.calendar = FixtureFactory.calendar
        let conversation = FixtureFactory.directConversation()
        let messages = [
            FixtureFactory.message(id: "1", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 8, 0), text: "Morning", conversationID: conversation.id),
            FixtureFactory.message(id: "2", senderID: FixtureFactory.sam.id, timestamp: FixtureFactory.date(2026, 4, 10, 12, 0), text: "Noon", conversationID: conversation.id)
        ]

        let configuration = ChatThreadConfiguration(
            dateSeparatorStrategy: .dayChangeAndLargeGap(60 * 60),
            messageContextMenuActions: { _, _ in [] }
        )
        let items = engine.makeItems(conversation: conversation, messages: messages, configuration: configuration)
        let separatorCount = items.filter {
            if case .dateSeparator = $0 { return true }
            return false
        }.count

        XCTAssertEqual(separatorCount, 2)
    }
}
