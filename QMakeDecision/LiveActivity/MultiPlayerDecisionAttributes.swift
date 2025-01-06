import ActivityKit
import Foundation

public struct MultiPlayerDecisionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var connectedPeers: Int
        public var votedPeers: Int
        public var currentResult: [String: Int] // "正面": 3, "反面": 2
        public var lastVoteTime: Date
        public var isComplete: Bool
        
        public init(
            connectedPeers: Int,
            votedPeers: Int,
            currentResult: [String: Int],
            lastVoteTime: Date,
            isComplete: Bool
        ) {
            self.connectedPeers = connectedPeers
            self.votedPeers = votedPeers
            self.currentResult = currentResult
            self.lastVoteTime = lastVoteTime
            self.isComplete = isComplete
        }
    }
    
    public let decisionTitle: String
    public let decisionId: String
    public let totalExpectedVotes: Int
    
    public init(
        decisionTitle: String,
        decisionId: String,
        totalExpectedVotes: Int
    ) {
        self.decisionTitle = decisionTitle
        self.decisionId = decisionId
        self.totalExpectedVotes = totalExpectedVotes
    }
} 
