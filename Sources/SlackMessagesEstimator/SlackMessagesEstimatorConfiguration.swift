//
//  SlackMessagesEstimatorConfiguration.swift
//  SlackMessagesEstimator
//
//  Created by Roman Podymov on 30/01/2024.
//  Copyright © 2024 SlackMessagesEstimator. All rights reserved.
//

import Foundation
import Yams

public struct SlackMessagesEstimatorConfiguration: Codable {
    public let token: String
    public let emojisToMessages: EmojisToMessages
}

public struct EmojisToMessages: Codable {
    public let reportChannelName: String?
    public let excludeUsers: [String]?
    public let emojisToMessagesCases: [EmojisToMessagesCase]
}

public struct EmojisToMessagesCase: Codable {
    public let emojis: [String]
    public let textProperties: TextProperties
}

public struct TextProperties: Codable {
    public let startsWith: [String]?
    public let endsWith: [String]?
    public let contains: [String]?
}

public func createSlackMessagesEstimatorConfiguration(
    configurationFilePath: URL
) -> SlackMessagesEstimatorConfiguration? {
    let decoder = YAMLDecoder()
    guard let textYML = try? String(contentsOf: configurationFilePath),
        let decoded = try? decoder.decode(SlackMessagesEstimatorConfiguration.self, from: textYML) else {
        return nil
    }
    return decoded
}
