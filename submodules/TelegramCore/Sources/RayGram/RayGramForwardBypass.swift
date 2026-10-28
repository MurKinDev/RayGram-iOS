import Foundation
import Postbox
import SwiftSignalKit

public final class RayGramForwardBypass {
    public static func rewriteProtectedForwards(account: Account, peerId: PeerId, messages: [EnqueueMessage]) -> Signal<[EnqueueMessage], NoError> {
        guard RayGramSettings.bypassNoForwards else {
            return .single(messages)
        }
        
        var hasForwards = false
        for message in messages {
            if case .forward = message {
                hasForwards = true
                break
            }
        }
        if !hasForwards {
            return .single(messages)
        }
        
        return account.postbox.transaction { transaction -> [EnqueueMessage] in
            var localGroupingKeyBySourceKey: [Int64: Int64] = [:]
            var result: [EnqueueMessage] = []
            
            for message in messages {
                switch message {
                case let .forward(sourceId, threadId, grouping, forwardAttributes, correlationId):
                    if let sourceMessage = transaction.getMessage(sourceId) {
                        var isProtected = sourceMessage.flags.contains(.CopyProtected)
                        if !isProtected, let peer = transaction.getPeer(sourceMessage.id.peerId) {
                            if let group = peer as? TelegramGroup, group.flags.contains(.copyProtectionEnabled) {
                                isProtected = true
                            } else if let channel = peer as? TelegramChannel, channel.flags.contains(.copyProtectionEnabled) {
                                isProtected = true
                            }
                        }
                        
                        if isProtected {
                            var mediaReference: AnyMediaReference?
                            if let media = sourceMessage.media.first {
                                mediaReference = .standalone(media: media)
                            }
                            
                            var text = sourceMessage.text
                            var hidesCaption = false
                            if let media = mediaReference?.media, media is TelegramMediaImage || media is TelegramMediaFile, forwardAttributes.contains(where: { ($0 as? ForwardOptionsMessageAttribute)?.hideCaptions == true }) {
                                text = ""
                                hidesCaption = true
                            }
                            
                            let attributes = forwardCopyRequestedAttributes(sourceAttributes: sourceMessage.attributes, forwardAttributes: forwardAttributes, hidesCaption: hidesCaption)
                            
                            let groupingKey = forwardGroupingKey(grouping: grouping, sourceGroupingKey: sourceMessage.groupingKey, generatedKeys: &localGroupingKeyBySourceKey)
                            
                            result.append(.message(
                                text: text,
                                attributes: attributes,
                                inlineStickers: [:],
                                mediaReference: mediaReference,
                                threadId: threadId,
                                replyToMessageId: threadId.flatMap { EngineMessageReplySubject(messageId: MessageId(peerId: peerId, namespace: Namespaces.Message.Cloud, id: Int32(clamping: $0)), quote: nil, innerSubject: nil) },
                                replyToStoryId: nil,
                                localGroupingKey: groupingKey,
                                correlationId: correlationId,
                                bubbleUpEmojiOrStickersets: []
                            ))
                            continue
                        }
                    }
                    result.append(message)
                case .message:
                    result.append(message)
                }
            }
            
            return result
        }
    }
}
