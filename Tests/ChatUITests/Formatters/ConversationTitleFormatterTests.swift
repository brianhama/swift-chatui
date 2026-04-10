import XCTest
@testable import ChatUI

final class ConversationTitleFormatterTests: XCTestCase {
    func testUsesExplicitTitleWhenProvided() {
        let formatter = ConversationTitleFormatter()
        let conversation = ChatConversation(
            id: "group",
            kind: .group,
            explicitTitle: "Launch Team",
            participants: [FixtureFactory.me, FixtureFactory.sam, FixtureFactory.taylor],
            currentUserID: FixtureFactory.me.id
        )

        XCTAssertEqual(formatter.title(for: conversation), "Launch Team")
    }

    func testGeneratesDirectConversationTitleFromOtherParticipant() {
        let formatter = ConversationTitleFormatter()
        XCTAssertEqual(formatter.title(for: FixtureFactory.directConversation()), "Sam")
    }

    func testGeneratesGroupConversationFallbackTitle() {
        let formatter = ConversationTitleFormatter()
        XCTAssertEqual(formatter.title(for: FixtureFactory.groupConversation()), "Sam, Taylor and 1 others")
    }
}
