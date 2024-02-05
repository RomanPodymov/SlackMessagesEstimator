//
//  SlackMessagesEstimatorTests.swift
//  SlackMessagesEstimator
//
//  Created by Roman Podymov on 05/02/2024.
//  Copyright © 2024 SlackMessagesEstimator. All rights reserved.
//

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

        testEmojisToMessagesCase(emojisCase: emojisToMessagesCases[0], emojisCount: 2)
        testEmojisToMessagesCase(emojisCase: emojisToMessagesCases[1], emojisCount: 3)
    }

    private func testEmojisToMessagesCase(emojisCase: EmojisToMessagesCase, emojisCount: Int) {
        XCTAssertEqual(emojisCase.emojis.count, emojisCount)
        XCTAssertEqual(emojisCase.textProperties.startsWith?[0], "first string")
        XCTAssertEqual(emojisCase.textProperties.endsWith?[0], "second string")
        XCTAssertEqual(emojisCase.textProperties.contains?[0], "third string")
    }
}
