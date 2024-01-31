import XCTest
@testable import SlackMessagesEstimator

private struct Resource {
    let name: String
    let type: String
    let url: URL

    init(name: String, type: String, sourceFile: StaticString = #file) throws {
        self.name = name
        self.type = type

        let testCaseURL = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
        let testsFolderURL = testCaseURL.deletingLastPathComponent()
        let resourcesFolderURL = testsFolderURL.deletingLastPathComponent().appendingPathComponent("Resources", isDirectory: true)
        self.url = resourcesFolderURL.appendingPathComponent("\(name).\(type)", isDirectory: false)
  }
}

final class SlackMessagesEstimatorTests: XCTestCase {
    func testSlackMessagesEstimatorConfiguration() throws {
        let configurationFilePath = try Resource(name: "sme", type: "yml").url
        let slackMessagesEstimatorConfiguration: SlackMessagesEstimatorConfiguration! = createSlackMessagesEstimatorConfiguration(
            configurationFilePath: configurationFilePath
        )
        XCTAssertNotNil(slackMessagesEstimatorConfiguration)
        let token = slackMessagesEstimatorConfiguration.token
        XCTAssertEqual(token, "anyString")
        let reportChannelName = slackMessagesEstimatorConfiguration.emojisToMessages.reportChannelName
        XCTAssertEqual(reportChannelName, "channelName")
        let excludeUsers = slackMessagesEstimatorConfiguration.emojisToMessages.excludeUsers
        XCTAssertEqual(excludeUsers?.count, 2)
        XCTAssertEqual(excludeUsers?[0], "first user")
        XCTAssertEqual(excludeUsers?[1], "second user")
        let emojisToMessagesCases = slackMessagesEstimatorConfiguration.emojisToMessages.emojisToMessagesCases
        XCTAssertEqual(emojisToMessagesCases.count, 2)
        XCTAssertEqual(emojisToMessagesCases[0].emojis.count, 2)
        XCTAssertEqual(emojisToMessagesCases[1].emojis.count, 3)
        XCTAssertEqual(emojisToMessagesCases[0].textProperties.startsWith?[0], "first string")
        XCTAssertEqual(emojisToMessagesCases[0].textProperties.endsWith?[0], "second string")
        XCTAssertEqual(emojisToMessagesCases[0].textProperties.contains?[0], "third string")
        XCTAssertEqual(emojisToMessagesCases[1].textProperties.startsWith?[0], "first string")
        XCTAssertEqual(emojisToMessagesCases[1].textProperties.endsWith?[0], "second string")
        XCTAssertEqual(emojisToMessagesCases[1].textProperties.contains?[0], "third string")
    }
}
