import SwiftUI

struct ParticipantActionView: View {
    @ObservedObject var decisionManager: DecisionManager
    @Binding var diceResult: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            if !decisionManager.connectedPeers.isEmpty {
                if decisionManager.canRollDice {
                    if !decisionManager.hasRolledDice {
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
                    } else {
                        Text("已完成投骰")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("等待发起者开始决策...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("等待连接到发起者...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
} 