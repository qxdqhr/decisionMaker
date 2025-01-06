import SwiftUI

struct CoinFlipView: View {
    @State private var isFlipping = false
    @State private var result: Bool = true
    @State private var rotationDegrees = 0.0
    @State private var showResult = false
    
    private let flipDuration = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                // 硬币视图
                ZStack {
                    // 硬币正面
                    Circle()
                        .fill(Color.yellow)
                        .overlay(
                            Text(isFlipping ? "" : "正")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .rotation3DEffect( // 添加反向旋转以保持文字正向
                                    .degrees(rotationDegrees),
                                    axis: (x: 0, y: -1, z: 0)
                                )
                        )
                        .opacity(result ? 1 : 0)
                    
                    // 硬币反面
                    Circle()
                        .fill(Color.yellow)
                        .overlay(
                            Text(isFlipping ? "" : "反")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .rotation3DEffect( // 添加反向旋转以保持文字正向
                                    .degrees(rotationDegrees),
                                    axis: (x: 0, y: -1, z: 0)
                                )
                        )
                        .opacity(result ? 0 : 1)
                }
                .frame(width: 160, height: 160)
                .rotation3DEffect(
                    .degrees(rotationDegrees),
                    axis: (x: 0, y: 1, z: 0)
                )
                .shadow(radius: 10)
                  // 结果显示区域
                VStack(spacing: 20) {
                    if showResult {
                        Text(result ? "正面" : "反面")
                            .font(.title)
                            .foregroundColor(.primary)
                            .transition(.opacity)
                    }
                }
                .frame(height: 44) // 固定高度避免结果显示时的跳动
                
                Spacer(minLength: 20) // 确保最小间距
                
                Button(action: flipCoin) {
                    Text(isFlipping ? "抛硬币中..." : "抛硬币")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(isFlipping ? Color.gray : Color.blue)
                        .cornerRadius(25)
                }
                .disabled(isFlipping)
                .padding(.bottom, 30)
            }
            .navigationTitle("抛硬币")
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private func flipCoin() {
        guard !isFlipping else { return }
        
        isFlipping = true
        showResult = false
        
        // 生成随机结果
        result = Bool.random()
        
        // 重置旋转角度并创建新的翻转动画
        rotationDegrees = 0 // 重置旋转角度
        
        withAnimation(.easeInOut(duration: flipDuration)) {
            let flips = Double(Int.random(in: 6...10))
            rotationDegrees = 180 * flips // 使用赋值而不是累加
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration) {
            withAnimation {
                showResult = true
                isFlipping = false
            }
        }
    }
}
