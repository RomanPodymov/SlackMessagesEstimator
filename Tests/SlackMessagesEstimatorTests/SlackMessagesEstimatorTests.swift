import XCTest
@testable import SlackMessagesEstimator

final class SlackMessagesEstimatorTests: XCTestCase {
    func testSlackMessagesEstimatorConfiguration() {
        let configurationFileDirectory = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath
        )
        let configurationFilePath = URL(
            fileURLWithPath: "sme.yml",
            relativeTo: configurationFileDirectory
        )
        let slackMessagesEstimatorConfiguration = createSlackMessagesEstimatorConfiguration(
            configurationFilePath: configurationFilePath
        )
        let token = slackMessagesEstimatorConfiguration?.token
        XCTAssertEqual(token, "anyString")
        let reportChannelName = slackMessagesEstimatorConfiguration?.emojisToMessages.reportChannelName
        XCTAssertEqual(reportChannelName, "channelName")
        let excludeUsers = slackMessagesEstimatorConfiguration?.emojisToMessages.excludeUsers
        XCTAssertEqual(excludeUsers?.count, 2)
        XCTAssertEqual(excludeUsers?[0], "first user")
        XCTAssertEqual(excludeUsers?[1], "second user")
        let emojisToMessagesCases = slackMessagesEstimatorConfiguration?.emojisToMessages.emojisToMessagesCases
        XCTAssertEqual(emojisToMessagesCases?.count, 2)
        XCTAssertEqual(emojisToMessagesCases?[0].emojis.count, 2)
        XCTAssertEqual(emojisToMessagesCases?[1].emojis.count, 3)
        XCTAssertEqual(emojisToMessagesCases?[0].textProperties.startsWith?[0], "first string")
        XCTAssertEqual(emojisToMessagesCases?[0].textProperties.endsWith?[0], "second string")
        XCTAssertEqual(emojisToMessagesCases?[0].textProperties.contains?[0], "third string")
    }

    static var allTests = [
        ("testSlackMessagesEstimatorConfiguration", testSlackMessagesEstimatorConfiguration),
    ]
}
