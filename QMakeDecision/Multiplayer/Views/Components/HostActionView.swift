import SwiftUI

struct HostActionView: View {
    @ObservedObject var decisionManager: DecisionManager
    @Binding var diceResult: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            if decisionManager.connectedPeers.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("等待参与者加入...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                if decisionManager.isDecisionCompleted {
                    // 所有人都完成决策后显示的按钮
                    Button(action: {
                        decisionManager.resetDecision()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("重新开始决策")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                } else {
                    // 正常的开始决策和投骰子按钮
                    if decisionManager.canStartDecision {
                        Button(action: {
                            decisionManager.startVoting()
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("开始决策")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    
                    if decisionManager.shouldShowDiceButton {
                        Button(action: {
                            let result = Int.random(in: 1...6)
                            diceResult = result
                            decisionManager.sendDiceResult(result)
                        }) {
                            HStack {
                                Image(systemName: "dice.fill")
                                Text("投骰子")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
} 