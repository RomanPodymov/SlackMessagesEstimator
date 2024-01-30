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
    public var token: String
    public var emojisToMessages: EmojisToMessages
}

public struct EmojisToMessages: Codable {
    public var reportChannelName: String?
    public var excludeUsers: [String]?
    public var emojisToMessagesCases: [EmojisToMessagesCase]
}

public struct EmojisToMessagesCase: Codable {
    public var emojis: [String]
    public var textProperties: TextProperties
}

public struct TextProperties: Codable {
    public var startsWith: [String]?
    public var endsWith: [String]?
    public var contains: [String]?
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
