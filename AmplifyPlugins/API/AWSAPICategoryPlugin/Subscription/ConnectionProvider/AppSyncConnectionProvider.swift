//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Appsync Real time connection that connects to subscriptions
/// through websocket.
/// Manages the lifecycle of a websocket connection
class AppSyncConnectionProvider: ConnectionProvider {

    let url: URL
    let websocketProvider: WebsocketProvider

    var state: ConnectionState = .disconnected(error: nil)
    var listener: ConnectionProviderCallback?
    var messageInterceptors: [MessageInterceptor] = []

    /// Serial queue for maintaining the connection state in sync with the websocket connection
    let serialConnectionQueue = DispatchQueue(label: "com.amazonaws.AppSyncRealTimeConnectionProvider.serialQueue")

    convenience init(for url: URL, interceptor: AuthInterceptor) {
        let websocketProvider = StarscreamWebsocketProvider(url: url)
        websocketProvider.addInterceptor(AppSyncSubscriptionInterceptor())
        websocketProvider.addInterceptor(interceptor)
        self.init(url: url, websocketProvider: websocketProvider)
    }

    init(url: URL, websocketProvider: WebsocketProvider) {
        self.url = url
        self.websocketProvider = websocketProvider
        websocketProvider.setListener { [weak self] (websocketEvent) in
            guard let self = self else {
                return
            }

            self.onWebsocketEvent(event: websocketEvent)
        }
    }

    // MARK: - ConnectionProvider methods

    /// Begins websocket handshake if it is disconnected.
    /// Signals listener when already connected or connecting
    func connect() {
        switch state {
        case .disconnected:
            websocketProvider.connect()
        case .connecting, .connected:
            listener?(.connection(state))
        }
    }

    /// Begins websocket disconnect if it is connected or connecting.
    /// Signals listener if it is disconnected already.
    func disconnect() {
        switch state {
        case .connecting, .connected:
            websocketProvider.disconnect()
        case .disconnected:
            listener?(.connection(state))
        }
    }

    func subscribe(_ subscriptionItem: SubscriptionItem) {
        print("subscribe, sending start subscription message...")
        let payload: AppSyncMessage.Payload
        do {
            payload = try convertToPayload(for: subscriptionItem.requestString,
                                           variables: subscriptionItem.variables)
        } catch {
            subscriptionItem.subscriptionEventHandler(.failed(error), subscriptionItem)
            return
        }

        let message = AppSyncMessage(id: subscriptionItem.identifier,
                                     payload: payload,
                                     type: .subscribe("start"))
        do {
            try write(message)
        } catch {
            let error = ConnectionProviderError.jsonParse(message.id, error)
            listener?(.subscriptionError(subscriptionItem.identifier, error))
        }
    }

    func unsubscribe(_ identifier: String) {
        print("sendStartSubscriptionMessage, sending start subscription message...")
        let message = AppSyncMessage(id: identifier, type: .unsubscribe("stop"))
        do {
            try write(message)
        } catch {
            let error = ConnectionProviderError.jsonParse(message.id, error)
            listener?(.subscriptionError(identifier, error))
        }
    }

    var isConnected: Bool {
        if case .connected = state {
            return true
        }

        return false
    }

    func setListener(_ callback: @escaping ConnectionProviderCallback) {
        listener = callback
    }

    // MARK: - Private

    /// Send Connection Init message to finish the connection handshake
    func sendConnectionInitMessage() {
        switch state {
        case .connecting:
            print("sendConnectionInitMessage, sending init message...")
            let message = AppSyncMessage(type: .connectionInit("connection_init"))
            do {
                try write(message)
            } catch {
                serialConnectionQueue.async {[weak self] in
                    guard let self = self else {
                        return
                    }
                    self.state = .disconnected(error: ConnectionProviderError.connection(nil))
                    self.listener?(.connection(self.state))
                }
            }
        case .disconnected, .connected:
            break
        }
    }

    private func write(_ appSyncMessage: AppSyncMessage) throws {
        do {
            let message = try encode(appSyncMessage: appSyncMessage)
            websocketProvider.write(message)
        } catch {
            throw error
        }
    }

    // MARK: - Helpers

    private func convertToPayload(for query: String, variables: [String: Any]?) throws -> AppSyncMessage.Payload {
        var dataDict: [String: Any] = ["query": query]
        if let subVariables = variables {
            dataDict["variables"] = subVariables
        }
        var payload = AppSyncMessage.Payload()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
            payload.data = String(data: jsonData, encoding: .utf8)
        } catch {
            print(error)
            let jsonError = ConnectionProviderError.jsonParse(nil, error)
            throw jsonError
        }
        return payload
    }

    private func encode(appSyncMessage: AppSyncMessage) throws -> String {
        do {
            let signedMessage = interceptMessage(appSyncMessage, for: url)
            let jsonData = try JSONEncoder().encode(signedMessage)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ConnectionProviderError.jsonParse(appSyncMessage.id, nil)
            }
            return jsonString
        } catch {
            throw ConnectionProviderError.jsonParse(appSyncMessage.id, error)
        }
    }
}
