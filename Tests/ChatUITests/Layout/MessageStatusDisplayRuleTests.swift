import XCTest
@testable import ChatUI

final class MessageStatusDisplayRuleTests: XCTestCase {
    func testOnlyLastOutgoingNonFailedMessageShowsStatus() {
        let rule = MessageStatusDisplayRule()
        let messages = [
            FixtureFactory.message(
                id: "1",
                senderID: FixtureFactory.me.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 0),
                text: "Hello",
                status: .sent
            ),
            FixtureFactory.message(
                id: "2",
                senderID: FixtureFactory.sam.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 1),
                text: "Hey"
            ),
            FixtureFactory.message(
                id: "3",
                senderID: FixtureFactory.me.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 2),
                text: "Latest",
                status: .delivered
            )
        ]

        XCTAssertFalse(rule.shouldShowStatus(for: messages[0], in: messages, currentUserID: FixtureFactory.me.id))
        XCTAssertFalse(rule.shouldShowStatus(for: messages[1], in: messages, currentUserID: FixtureFactory.me.id))
        XCTAssertTrue(rule.shouldShowStatus(for: messages[2], in: messages, currentUserID: FixtureFactory.me.id))
    }

    func testFailedMessagesAlwaysShowStatus() {
        let rule = MessageStatusDisplayRule()
        let messages = [
            FixtureFactory.message(
                id: "1",
                senderID: FixtureFactory.me.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 0),
                text: "Oops",
                status: .failed(reason: nil)
            ),
            FixtureFactory.message(
                id: "2",
                senderID: FixtureFactory.me.id,
                timestamp: FixtureFactory.date(2026, 4, 10, 9, 1),
                text: "Later",
                status: .sent
            )
        ]

        XCTAssertTrue(rule.shouldShowStatus(for: messages[0], in: messages, currentUserID: FixtureFactory.me.id))
        XCTAssertTrue(rule.shouldShowStatus(for: messages[1], in: messages, currentUserID: FixtureFactory.me.id))
    }
}
