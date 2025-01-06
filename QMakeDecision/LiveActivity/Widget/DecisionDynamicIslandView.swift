import SwiftUI
import ActivityKit
import WidgetKit

struct DecisionDynamicIslandView: View {
    let context: ActivityViewContext<MultiPlayerDecisionAttributes>
    
    var body: some View {
        VStack {
            HStack {
                Text("正面: \(context.state.currentResult["正面", default: 0])")
                Spacer()
                Text("反面: \(context.state.currentResult["反面", default: 0])")
            }
            // 修改这里，使用 context.attributes
            Text("已投票: \(context.state.votedPeers)/\(context.attributes.totalExpectedVotes)")
        }
    }
}
