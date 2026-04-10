import XCTest
@testable import ChatUIDemo

@MainActor
final class DemoStoreTests: XCTestCase {
    func testSeededStoreCreatesConversationsAndSelection() {
        let store = DemoStore()

        XCTAssertFalse(store.previews.isEmpty)
        XCTAssertNotNil(store.activeConversation)
        XCTAssertEqual(store.filteredPreviews.count, store.previews.count)
    }

    func testSearchFiltersConversations() {
        let store = DemoStore()

        store.searchText = "Long Transcript"

        XCTAssertEqual(store.filteredPreviews.count, 1)
        XCTAssertEqual(store.filteredPreviews.first?.explicitTitle, "Long Transcript")
    }

    func testSendAppendsSendingMessageAndClearsDraft() {
        let store = DemoStore()
        guard let conversationID = store.activeConversation?.id else {
            XCTFail("Expected an active conversation")
            return
        }

        store.drafts[conversationID] = "Draft"
        let previousCount = store.activeMessages.count

        store.send("Hello from tests")

        XCTAssertEqual(store.activeMessages.count, previousCount + 1)
        XCTAssertEqual(store.activeMessages.last?.senderID, "me")
        XCTAssertEqual(store.activeMessages.last?.status, .sending)
        XCTAssertEqual(store.drafts[conversationID], "")
    }
}
