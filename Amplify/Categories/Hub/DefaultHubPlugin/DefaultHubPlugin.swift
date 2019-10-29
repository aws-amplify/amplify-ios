//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

/// The default Hub plugin provided with the Amplify Framework
///
/// **No guaranteed delivery order**
///
/// DefaultHubCategoryPlugin distributes messages in order to listeners, but makes no guarantees about the order in
/// which a listener is called.
/// This plugin does not guarantee synchronization between message delivery and listener management. In other words, the
/// following sequence is not guaranteed to succeed:
///
///     plugin.listen(to: .custom("MyChannel") { event in print("event received: \(event)") }
///     plugin.dispatch(to: .custom("MyChannel"), payload: HubPayload("MY_EVENT"))
///
/// Instead, messages and listener states are guaranteed to be independently self-consistent. Callers can use
/// `hasListener(withToken:)` to check that a listener has been registered.
final public class DefaultHubCategoryPlugin: HubCategoryPlugin {
    /// Convenience property. Each instance of `DefaultHubCategoryPlugin` has the same key
    public static var key: String {
        return "DefaultHubCategoryPlugin"
    }

    private let dispatcher = HubChannelDispatcher()

    // MARK: - HubCategoryPlugin

    public var key: String {
        return type(of: self).key
    }

    /// For protocol conformance only--this plugin has no applicable configurations
    public func configure(using configuration: Any) throws {
        return
    }

    /// Removes listeners and empties the message queue
    public func reset(onComplete: @escaping BasicClosure) {
        dispatcher.destroy()
        onComplete()
    }

    public func dispatch(to channel: HubChannel, payload: HubPayload) {
        dispatcher.dispatch(to: channel, payload: payload)
    }

    public func listen(to channel: HubChannel,
                       isIncluded filter: HubFilter? = nil,
                       listener: @escaping HubListener) -> UnsubscribeToken {
        let filteredListener = FilteredListener(for: channel, filter: filter, listener: listener)
        dispatcher.insert(filteredListener)

        let unsubscribeToken = UnsubscribeToken(channel: channel, id: filteredListener.id)
        return unsubscribeToken
    }

    public func removeListener(_ token: UnsubscribeToken) {
        dispatcher.removeListener(withId: token.id)
    }

    // MARK: - Custom Plugin methods

    /// Returns true if the dispatcher has a listener registered with `token`
    ///
    /// - Parameter token: The UnsubscribeToken of the listener to check
    /// - Returns: True if the dispatcher has a listener registered with `token`
    public func hasListener(withToken token: UnsubscribeToken) -> Bool {
        return dispatcher.hasListener(withId: token.id)
    }

}
