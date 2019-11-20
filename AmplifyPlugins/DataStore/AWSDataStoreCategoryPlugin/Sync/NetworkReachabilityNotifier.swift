//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Reachability
import Combine

struct ReachabilityUpdate {
    let isOnline: Bool
}

class NetworkReachabilityNotifier {
    private var reachability: NetworkReachabilityProviding?
    private var allowsCellularAccess = true

    let reachabilityPublisher = PassthroughSubject<ReachabilityUpdate, Never>()

    public init(host: String,
                allowsCellularAccess: Bool,
                reachabilityFactory: NetworkReachabilityProvidingFactory.Type = Reachability.self) {
        self.reachability = reachabilityFactory.make(for: host)
        self.allowsCellularAccess = allowsCellularAccess

        // Add listener for Reachability and start its notifier
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(respondToReachabilityChange),
                                               name: .reachabilityChanged,
                                               object: nil)
        do {
            try reachability?.startNotifier()
        } catch {
            //TODO: Test effects of inability to start ReachabilitySwift
            print("Unable to start notifier from ReachabilitySwift")
        }
    }

    deinit {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        reachabilityPublisher.send(completion: Subscribers.Completion<Never>.finished)
    }

    func publisher() -> AnyPublisher<ReachabilityUpdate, Never> {
        return reachabilityPublisher
            .eraseToAnyPublisher()
    }

    // MARK: - Notifications
    @objc private func respondToReachabilityChange() {
        guard let reachability = reachability else {
            return
        }

        let isReachable: Bool
        switch reachability.connection {
        case .wifi:
            isReachable = true
        case .cellular:
            isReachable = allowsCellularAccess
        case .none, .unavailable:
            isReachable = false
        }

        let reachabilityMessageUpdate =  ReachabilityUpdate(isOnline: isReachable)
        reachabilityPublisher.send(reachabilityMessageUpdate)
    }

}

// MARK: - Reachability
extension Reachability: NetworkReachabilityProvidingFactory {
    public static func make(for hostname: String) -> NetworkReachabilityProviding? {
        return try? Reachability(hostname: hostname)
    }
}

extension Reachability: NetworkReachabilityProviding { }
