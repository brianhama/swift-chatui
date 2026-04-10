import XCTest
@testable import ChatUI

final class FixtureSanityTests: XCTestCase {
    func testFixtureCalendarUsesExpectedTimeZoneAndLocale() {
        XCTAssertEqual(FixtureFactory.calendar.timeZone.secondsFromGMT(), 0)
        XCTAssertEqual(FixtureFactory.calendar.locale?.identifier, "en_US_POSIX")
    }

    func testFixtureConversationsContainCurrentUser() {
        let direct = FixtureFactory.directConversation()
        let group = FixtureFactory.groupConversation()

        XCTAssertTrue(direct.participants.contains(where: { $0.id == direct.currentUserID }))
        XCTAssertTrue(group.participants.contains(where: { $0.id == group.currentUserID }))
    }
}
