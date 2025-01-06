import WidgetKit
import SwiftUI
import ActivityKit

struct DecisionWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MultiPlayerDecisionAttributes.self) { context in
            DecisionLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("正面: \(context.state.currentResult["正面", default: 0])")
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("反面: \(context.state.currentResult["反面", default: 0])")
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // 修改这里，使用 context.attributes 而不是 context.state
                    Text("已投票: \(context.state.votedPeers)/\(context.attributes.totalExpectedVotes)")
                }
            } compactLeading: {
                Text("\(context.state.votedPeers)")
            } compactTrailing: {
                // 修改这里，使用 context.attributes
                Text("/\(context.attributes.totalExpectedVotes)")
            } minimal: {
                Text("\(context.state.votedPeers)")
            }
        }
    }
}
