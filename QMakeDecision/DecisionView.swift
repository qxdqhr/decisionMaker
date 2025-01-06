import SwiftUI

struct DecisionCard: View {
    let title: String
    let systemImage: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title)
                Text(title)
                    .font(.title2)
                    .bold()
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DecisionView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink(destination: CoinFlipView()) {
                        DecisionCard(
                            title: "抛硬币",
                            systemImage: "circle.lefthalf.filled",
                            description: "用硬币帮你做出二选一的决定",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: DiceRollView()) {
                        DecisionCard(
                            title: "掷骰子",
                            systemImage: "dice",
                            description: "随机产生1-6的数字",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: RouletteView()) {
                        DecisionCard(
                            title: "转轮盘",
                            systemImage: "circle.circle",
                            description: "在多个选项中随机选择一个",
                            color: .orange
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("随机决策")
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
