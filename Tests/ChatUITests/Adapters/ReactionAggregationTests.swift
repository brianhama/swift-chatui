import XCTest
@testable import ChatUI

final class ReactionAggregationTests: XCTestCase {
    func testAggregatesDuplicateEmojiIntoCounts() {
        let aggregator = ReactionAggregator()
        let reactions = [
            MessageReaction(id: "1", emoji: "👍", senderID: FixtureFactory.sam.id),
            MessageReaction(id: "2", emoji: "👍", senderID: FixtureFactory.taylor.id),
            MessageReaction(id: "3", emoji: "❤️", senderID: FixtureFactory.jordan.id)
        ]

        let aggregates = aggregator.aggregate(reactions)
        XCTAssertEqual(aggregates, [
            ReactionAggregate(emoji: "👍", count: 2),
            ReactionAggregate(emoji: "❤️", count: 1)
        ])
    }
}
