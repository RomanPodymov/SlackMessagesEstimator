import Foundation
import PromiseKit
import SlackKit

private extension SKWebAPI.WebAPI {
    func promiseToGetChannelsList(
        excludeArchived: Bool,
        excludeMembers: Bool
    ) -> Promise<[[String: Any]]?> {
        return Promise { resolver in
            channelsList(excludeArchived: excludeArchived, excludeMembers: excludeMembers, success: {
                resolver.fulfill($0)
            }, failure: {
                resolver.reject($0)
            })
        }
    }
    
    func promiseToGetUsersList() -> Promise<[[String: Any]]?> {
        return Promise { resolver in
            usersList(success: { list, _ in
                resolver.fulfill(list)
            }, failure: {
                resolver.reject($0)
            })
        }
    }

    func promiseForAuthenticationTest() -> Promise<(String?, String?)> {
        return Promise { resolver in
            self.authenticationTest { user, team in
                resolver.fulfill((user, team))
            } failure: { error in
                resolver.reject(error)
            }
        }
    }
}

public final class SlackMessagesEstimator {
    private let bot = SlackKit()
    private var reportChannelId: String?
    private var userNamesToIdsIgnore: [String:[String]]?
    private let slackMessagesEstimatorConfiguration: SlackMessagesEstimatorConfiguration
    
    public init?(configurationFilePath: URL) {
        guard let slackMessagesEstimatorConfiguration = createSlackMessagesEstimatorConfiguration(
            configurationFilePath: configurationFilePath
        ) else {
            return nil
        }
        self.slackMessagesEstimatorConfiguration = slackMessagesEstimatorConfiguration
        bot.addRTMBotWithAPIToken(slackMessagesEstimatorConfiguration.token)
        bot.addWebAPIAccessWithToken(slackMessagesEstimatorConfiguration.token)
    }
    
    public final func start() {
        guard let webAPI = bot.webAPI else {
            startListenMessages()
            return
        }

        firstly {
            when(
                fulfilled: webAPI.promiseToGetChannelsList(
                    excludeArchived: true,
                    excludeMembers: true
                ).recover { _ in
                    .value(nil)
                },
                webAPI.promiseToGetUsersList().recover { _ in
                    .value(nil)
                },
                webAPI.promiseForAuthenticationTest()
            )
        }.done { [weak self] channels, users, _ in
            self?.onChannelsLoaded(channels: channels)
            self?.onUsersLoaded(users: users)
        }.catch {
            fatalError($0.localizedDescription)
        }.finally { [weak self] in
            self?.startListenMessages()
        }
    }
    
    private func onChannelsLoaded(channels: [[String:Any]]?) {
        let reportChannelName = slackMessagesEstimatorConfiguration.emojisToMessages.reportChannelName
        reportChannelId = reportChannelName.flatMap { reportChannelNameValue in
            return channels?.first {
                $0["name_normalized"] as? String == reportChannelNameValue
            }
        }?["id"] as? String
    }
    
    private func onUsersLoaded(users: [[String:Any]]?) {
        guard let ignoreUsers = slackMessagesEstimatorConfiguration.emojisToMessages.excludeUsers else {
            userNamesToIdsIgnore = nil
            return
        }
        userNamesToIdsIgnore = users?.reduce(into: [String:[String]]()) { currentResult, user in
            guard let userName = user["name"] as? String, let userId = user["id"] as? String else {
                return
            }
            if ignoreUsers.contains(userName) {
                currentResult[userName, default: []] += [userId]
            }
        }
    }
    
    private func startListenMessages() {
        bot.notificationForEvent(.message) { [weak self] (event, _) in
            guard let strongSelf = self,
                let message = event.message,
                let messageText = message.text,
                let eventChannelId = event.channel?.id,
                eventChannelId != strongSelf.reportChannelId,
                let timestamp = message.ts else {
                return
            }
            if !strongSelf.shouldIgnore(message: message) {
                strongSelf.valuate(message: messageText, eventChannelId: eventChannelId, timestamp: timestamp)
            }
        }
    }
    
    private func shouldIgnore(message: Message) -> Bool {
        guard let user = message.user,
            let userNamesToIdsIgnore = userNamesToIdsIgnore else {
            return false
        }
        return userNamesToIdsIgnore.contains { $0.value.contains(user) }
    }
    
    private func valuate(message: String, eventChannelId: String, timestamp: String) {
        slackMessagesEstimatorConfiguration.emojisToMessages.emojisToMessagesCases.forEach { emojisToMessagesCase in
            if let startsWith = emojisToMessagesCase.textProperties.startsWith,
                startsWith.contains(where: { message.hasPrefix($0) }) {
                emojisToMessagesCase.emojis.forEach { addReactionToMessage(emoji: $0, eventChannelId: eventChannelId, message: message, timestamp: timestamp) }
            }
            if let contains = emojisToMessagesCase.textProperties.contains,
                contains.contains(where: { message.contains($0) }) {
                emojisToMessagesCase.emojis.forEach { addReactionToMessage(emoji: $0, eventChannelId: eventChannelId, message: message, timestamp: timestamp) }
            }
            if let endsWith = emojisToMessagesCase.textProperties.endsWith,
                endsWith.contains(where: { message.hasSuffix($0) }) {
                emojisToMessagesCase.emojis.forEach { addReactionToMessage(emoji: $0, eventChannelId: eventChannelId, message: message, timestamp: timestamp) }
            }
        }
    }
    
    private func addReactionToMessage(emoji: String, eventChannelId: String, message: String, timestamp: String) {
        bot.webAPI?.addReactionToMessage(
            name: emoji,
            channel: eventChannelId,
            timestamp: timestamp,
            success: { [weak self] (_) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.sendReportMessage(emoji: emoji, message: message)
            }, failure: { _ in

            }
        )
    }
    
    private func sendReportMessage(emoji: String, message: String) {
        guard let reportChannelId = reportChannelId else {
            return
        }
        bot.webAPI?.sendMessage(channel: reportChannelId, text: "I did it with \(emoji) for message \(message)", success: { _, _ in
            
        }, failure: { _ in
            
        })
    }
}
