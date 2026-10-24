import Foundation
import TelegramApi
import Postbox
import SwiftSignalKit
import MtProtoKit

private typealias SignalKitTimer = SwiftSignalKit.Timer


private final class AccountPresenceManagerImpl {
    private let queue: Queue
    private let network: Network
    let isPerformingUpdate = ValuePromise<Bool>(false, ignoreRepeated: true)
    
    private var shouldKeepOnlinePresenceDisposable: Disposable?
    private let currentRequestDisposable = MetaDisposable()
    private var onlineTimer: SignalKitTimer?
    private var offlineAfterMessageTimer: SignalKitTimer?
    
    private var settingsNotificationObserver: AnyObject?
    private var messageSentNotificationObserver: AnyObject?
    
    private var wasOnline: Bool = false
    private var isOnlineOnServer: Bool = false
    
    init(queue: Queue, shouldKeepOnlinePresence: Signal<Bool, NoError>, network: Network) {
        self.queue = queue
        self.network = network
        
        self.shouldKeepOnlinePresenceDisposable = (shouldKeepOnlinePresence
        |> distinctUntilChanged
        |> deliverOn(self.queue)).start(next: { [weak self] value in
            guard let `self` = self else {
                return
            }
            if self.wasOnline != value {
                self.wasOnline = value
                self.updatePresence(value)
            }
        })
        
        self.settingsNotificationObserver = NotificationCenter.default.addObserver(
            forName: RayGramSettings.didChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.queue.async {
                strongSelf.settingsChanged()
            }
        }
        
        self.messageSentNotificationObserver = NotificationCenter.default.addObserver(
            forName: RayGramSettings.didSendMessageNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.queue.async {
                strongSelf.onMessageSent()
            }
        }
    }
    
    deinit {
        assert(self.queue.isCurrent())
        self.shouldKeepOnlinePresenceDisposable?.dispose()
        self.currentRequestDisposable.dispose()
        self.onlineTimer?.invalidate()
        self.offlineAfterMessageTimer?.invalidate()
        if let observer = self.settingsNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.messageSentNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func settingsChanged() {
        if RayGramSettings.ghostOnline {
            self.onlineTimer?.invalidate()
            self.onlineTimer = nil
            if self.isOnlineOnServer {
                self.isOnlineOnServer = false
                self.sendOfflineRequest()
            }
        } else {
            if self.wasOnline && !self.isOnlineOnServer {
                self.updatePresence(true)
            }
        }
    }
    
    private func onMessageSent() {
        if RayGramSettings.ghostOnline {
            self.offlineAfterMessageTimer?.invalidate()
            let timer = SignalKitTimer(timeout: 1.5, repeat: false, completion: { [weak self] in
                guard let strongSelf = self else { return }
                if RayGramSettings.ghostOnline {
                    strongSelf.sendOfflineRequest()
                }
            }, queue: self.queue)
            self.offlineAfterMessageTimer = timer
            timer.start()
        }
    }
    
    private func updatePresence(_ isOnline: Bool) {
        if isOnline {
            if RayGramSettings.ghostOnline {
                self.onlineTimer?.invalidate()
                self.onlineTimer = nil
                if self.isOnlineOnServer {
                    self.isOnlineOnServer = false
                    self.sendOfflineRequest()
                }
            } else {
                self.isOnlineOnServer = true
                let timer = SignalKitTimer(timeout: 30.0, repeat: false, completion: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.updatePresence(true)
                }, queue: self.queue)
                self.onlineTimer = timer
                timer.start()
                self.sendOnlineRequest()
            }
        } else {
            self.onlineTimer?.invalidate()
            self.onlineTimer = nil
            self.offlineAfterMessageTimer?.invalidate()
            self.offlineAfterMessageTimer = nil
            if RayGramSettings.ghostOnline {
                if self.isOnlineOnServer {
                    self.isOnlineOnServer = false
                    self.sendOfflineRequest()
                }
            } else {
                self.isOnlineOnServer = false
                self.sendOfflineRequest()
            }
        }
    }
    
    private func sendOnlineRequest() {
        let request: Signal<Api.Bool, MTRpcError> = self.network.request(Api.functions.account.updateStatus(offline: .boolFalse))
        self.isPerformingUpdate.set(true)
        self.currentRequestDisposable.set((request
        |> `catch` { _ -> Signal<Api.Bool, NoError> in
            return .single(.boolFalse)
        }
        |> deliverOn(self.queue)).start(completed: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isPerformingUpdate.set(false)
        }))
    }
    
    private func sendOfflineRequest() {
        let request: Signal<Api.Bool, MTRpcError> = self.network.request(Api.functions.account.updateStatus(offline: .boolTrue))
        self.isPerformingUpdate.set(true)
        self.currentRequestDisposable.set((request
        |> `catch` { _ -> Signal<Api.Bool, NoError> in
            return .single(.boolFalse)
        }
        |> deliverOn(self.queue)).start(completed: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isPerformingUpdate.set(false)
        }))
    }
}

final class AccountPresenceManager {
    private let queue = Queue()
    private let impl: QueueLocalObject<AccountPresenceManagerImpl>
    
    init(shouldKeepOnlinePresence: Signal<Bool, NoError>, network: Network) {
        let queue = self.queue
        self.impl = QueueLocalObject(queue: self.queue, generate: {
            return AccountPresenceManagerImpl(queue: queue, shouldKeepOnlinePresence: shouldKeepOnlinePresence, network: network)
        })
    }
    
    func isPerformingUpdate() -> Signal<Bool, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.isPerformingUpdate.get().start(next: { value in
                    subscriber.putNext(value)
                }))
            }
            return disposable
        }
    }
}
