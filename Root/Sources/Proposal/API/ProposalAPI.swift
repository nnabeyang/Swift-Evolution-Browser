//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/03.
//

import Core
import Foundation
import class SwiftEvolutionAPI.ProposalClient
import struct SwiftEvolutionAPI.StatusClass

public protocol ProposalAPI {
    func fetch() async throws -> [Proposal]
}

public final class ProposalAPIClient: ProposalAPI {
    private let client = ProposalClient(config: .shared)

    public init() {}

    public func fetch() async throws -> [Proposal] {
        try await client.fetch()
            .map {
                Proposal(
                    id: $0.id,
                    title: $0.title.trimmingCharacters(in: .whitespaces),
                    star: false,
                    proposalURL: URL(string: "https://github.com/apple/swift-evolution/blob/main/proposals/\($0.link)")!,
                    status: convertStatus(status: $0.status)
                )
            }.reversed()
    }

    // Note:
    // It may be easier to deal with this in Codable.

    func convertStatus(status: StatusClass) -> Proposal.Status {
        switch status.state {
        case .accepted:
            return .accepted
        case .activeReview:
            return .activeReview
        case .awaitingReview:
            return .awaitingReview
        case .deferred:
            return .deferred
        case .implemented:
            return .implemented(version: status.version ?? "-")
        case .previewing:
            return .previewing
        case .rejected:
            return .rejected
        case .returnedForRevision:
            return .returnedForRevision
        case .withdrawn:
            return .withdrawn
        case .scheduledForReview:
            return .scheduledForReview
        }
    }
}
