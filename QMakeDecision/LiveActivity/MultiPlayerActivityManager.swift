import ActivityKit
import Foundation
class MultiPlayerActivityManager {
    static let shared = MultiPlayerActivityManager()
    private var currentActivity: Activity<MultiPlayerDecisionAttributes>? = nil
    
    private init() {}
    
    func startActivity(connectedPeers: Int) {
        let initialState = MultiPlayerDecisionAttributes.ContentState(
            connectedPeers: connectedPeers,
            votedPeers: 0,
            currentResult: ["正面": 0, "反面": 0],
            lastVoteTime: Date(),
            isComplete: false
        )
        
        let attributes = MultiPlayerDecisionAttributes(
            decisionTitle: "多人抛硬币",
            decisionId: UUID().uuidString,
            totalExpectedVotes: connectedPeers + 1
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState
            )
        } catch {
            print("启动 Live Activity 失败: \(error.localizedDescription)")
        }
    }
    
    func updateVotingStatus(result: Bool) {
        guard let activity = currentActivity else { return }
        
        Task {
            var newState = activity.contentState
            let key = result ? "正面" : "反面"
            newState.currentResult[key, default: 0] += 1
            newState.votedPeers += 1
            newState.lastVoteTime = Date()
            newState.isComplete = newState.votedPeers >= activity.attributes.totalExpectedVotes
            
            await activity.update(using: newState)
            
            if newState.isComplete {
                await activity.end()
            }
        }
    }
    
    func endActivity() {
        Task {
            await currentActivity?.end()
        }
    }
} 
