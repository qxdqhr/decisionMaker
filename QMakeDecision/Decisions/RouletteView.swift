import SwiftUI

struct RouletteView: View {
    // MARK: - Properties
    enum PointerPosition {
        case top, bottom, left, right
        
        var rotation: Double {
            switch self {
            case .top: return 0
            case .bottom: return 180
            case .left: return 90
            case .right: return 270
            }
        }
        
        var offset: CGPoint {
            let radius: CGFloat = 140  // 轮盘半径
            switch self {
            case .top:
                return CGPoint(x: 0, y: -radius)
            case .bottom:
                return CGPoint(x: 0, y: radius)
            case .left:
                return CGPoint(x: -radius, y: 0)
            case .right:
                return CGPoint(x: radius, y: 0)
            }
        }
    }
    
    let segments: [String]
    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow]
    let pointerPosition: PointerPosition
    
    @State private var wheelRotation: Double = 0
    @State private var isSpinning = false
    @State private var result: String = ""
    @State private var showResult = false
    
    // MARK: - Initialization
    init(segments: [String] = ["1", "2", "3", "4", "5", "6"],
         pointerPosition: PointerPosition = .top) {
        self.segments = segments
        self.pointerPosition = pointerPosition
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    // 轮盘背景
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 300, height: 300)
                    
                    // 轮盘分段
                    ZStack {
                        ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                            RouletteSegment(
                                text: segment,
                                color: colors[index % colors.count],
                                angle: Double(360/segments.count),
                                rotation: Double(index) * Double(360/segments.count)
                            )
                        }
                    }
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(wheelRotation))
                    
                    // 指针（固定不动）
                    PointerView(position: pointerPosition)
                }
                
                if showResult {
                    Text("结果：\(result)")
                        .font(.title)
                        .padding()
                        .transition(.opacity)
                }
                
                Spacer()
                
                Button(action: spin) {
                    Text(isSpinning ? "旋转中..." : "开始旋转")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(isSpinning ? Color.gray : Color.blue)
                        .cornerRadius(25)
                }
                .disabled(isSpinning)
                .padding(.bottom)
            }
            .navigationTitle("幸运轮盘")
        }
    }
    
    // MARK: - Methods
    private func spin() {
        guard !isSpinning else { return }
        
        isSpinning = true
        showResult = false
        
        let rotations = Double.random(in: 3...5)
        let randomAngle = Double.random(in: 0...360)
        let totalRotation = -(rotations * 360 + randomAngle)  // 改为负值，使轮盘逆时针旋转
        
        // 计算结果
        let finalAngle = (wheelRotation + totalRotation).truncatingRemainder(dividingBy: 360)
        let segmentAngle = 360.0 / Double(segments.count)
        
        // 计算基础分段索引
        var baseIndex = Int((-finalAngle / segmentAngle).rounded())
        // 确保索引为正
        while baseIndex < 0 {
            baseIndex += segments.count
        }
        baseIndex = baseIndex % segments.count
        
        // 根据指针位置调整索引
        let segmentIndex: Int
        switch pointerPosition {
        case .top:
            segmentIndex = baseIndex
        case .right:
            segmentIndex = (baseIndex + segments.count / 4) % segments.count
        case .bottom:
            segmentIndex = (baseIndex + segments.count / 2) % segments.count
        case .left:
            segmentIndex = (baseIndex + segments.count * 3 / 4) % segments.count
        }
        
        result = segments[segmentIndex]
        
        withAnimation(.easeInOut(duration: 3)) {
            wheelRotation += totalRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showResult = true
                isSpinning = false
            }
        }
    }
}

// MARK: - Supporting Views
struct RouletteSegment: View {
    let text: String
    let color: Color
    let angle: Double
    let rotation: Double
    
    var body: some View {
        Sector(angle: angle)
            .fill(color)
            .overlay(
                GeometryReader { geometry in
                    Text(text)
                        .font(.title2)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-rotation))
                        // 计算文字位置
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 4
                        )
                }
            )
            .rotationEffect(.degrees(rotation))
    }
}

struct Sector: Shape {
    let angle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: .degrees(0),
                   endAngle: .degrees(angle),
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct PointerView: View {
    let position: RouletteView.PointerPosition
    
    var body: some View {
        Triangle()
            .fill(Color.red)
            .frame(width: 16, height: 24)  // 稍微调小指针尺寸
            .rotationEffect(.degrees(position.rotation))
            .offset(x: position.offset.x, y: position.offset.y)
            .shadow(radius: 2)  // 添加阴影提升视觉效果
    }
}

// MARK: - Preview
#Preview {
    Group {
        RouletteView(segments: ["1", "2", "3", "4", "5", "6"], pointerPosition: .top)
        RouletteView(segments: ["1", "2", "3", "4"], pointerPosition: .left)
        RouletteView(segments: ["A", "B", "C"], pointerPosition: .right)
        RouletteView(segments: ["选项1", "选项2"], pointerPosition: .bottom)
    }
} 
