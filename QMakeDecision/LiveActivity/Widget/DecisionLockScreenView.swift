import SwiftUI
import ActivityKit
import WidgetKit

struct DecisionLockScreenView: View {
    let context: ActivityViewContext<MultiPlayerDecisionAttributes>
    
    var body: some View {
        VStack {
            HStack {
                Text("多人决策进行中")
                Spacer()
                // 修改这里，使用 context.attributes
                Text("\(context.state.votedPeers)/\(context.attributes.totalExpectedVotes)")
            }
            
            HStack {
                VStack {
                    Text("正面")
                    Text("\(context.state.currentResult["正面", default: 0])")
                }
                Divider()
                VStack {
                    Text("反面")
                    Text("\(context.state.currentResult["反面", default: 0])")
                }
            }
        }
        .padding()
    }
}
