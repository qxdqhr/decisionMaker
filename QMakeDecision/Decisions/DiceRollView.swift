import SwiftUI
import SceneKit
import Foundation
struct DiceRollView: View {
    // MARK: - Properties
    let diceCount: Int  // 添加骰子数量参数
    
    @State private var isRolling = false
    @State private var results: [Int]  // 移除初始值，在 init 中设置
    @State private var showResults = false
    @State private var diceNodes: [SCNNode] = []
    
    // MARK: - Scene Properties
    class SceneHolder: ObservableObject {
        var scene: SCNScene
        var cameraNode: SCNNode
        
        init() {
            scene = SCNScene()
            cameraNode = SCNNode()
        }
        
        func cleanup() {
            // 移除所有节点
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
            // 移除所有动画
            scene.rootNode.removeAllAnimations()
            // 清空场景
            scene = SCNScene()
            // 重置相机
            cameraNode = SCNNode()
        }
    }
    
    // 使用 @StateObject 来管理场景
    @StateObject private var sceneHolder = SceneHolder()
    
    // 更新属性定义
    private var scene: SCNScene { sceneHolder.scene }
    private var cameraNode: SCNNode { sceneHolder.cameraNode }
    
    // MARK: - Initialization
    init(diceCount: Int = 10) {  // 默认两个骰子
        self.diceCount = max(1, min(diceCount, 5))  // 限制骰子数量在1-5之间
        self._results = State(initialValue: Array(repeating: 1, count: self.diceCount))
    }
    
    // MARK: - Constants
    /// 骰子六个面的法向量
    private let faceNormals: [SCNVector3] = [
        SCNVector3(1, 0, 0),    // 右面 (1)
        SCNVector3(-1, 0, 0),   // 左面 (2)
        SCNVector3(0, 1, 0),    // 上面 (3)
        SCNVector3(0, -1, 0),   // 下面 (4)
        SCNVector3(0, 0, 1),    // 前面 (5)
        SCNVector3(0, 0, -1)    // 后面 (6)
    ]
    
    private let faceValues = [1, 2, 3, 4, 5, 6]
    
    var body: some View {
        NavigationView {
            VStack {
                // SceneKit 视图
                SceneView(
                    scene: scene,
                    pointOfView: cameraNode,
                    options: [.autoenablesDefaultLighting]
                )
                .frame(width: 300 * CGFloat(diceCount), height: 200)  // 加宽视图以容纳多个骰子
                
                if showResults {
                    VStack {
                        Text("总点数：\(results.reduce(0, +))")
                            .font(.title)
                        if diceCount > 1 {  // 只有多个骰子时才显示明细
                            Text("(\(results.map(String.init).joined(separator: " + ")))")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 10)
                    .transition(.opacity)
                }
                
                Spacer()
                
                Button(action: rollDice) {
                    Text(isRolling ? "骰子滚动中..." : "掷骰子")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(isRolling ? Color.gray : Color.blue)
                        .cornerRadius(25)
                }
                .disabled(isRolling)
                .padding(.bottom, 10)
            }
            .navigationTitle(diceCount > 1 ? "掷骰子" : "掷一个骰子")
            .onAppear(perform: setupScene)
            .onDisappear {
                // 清理场景资源
                sceneHolder.cleanup()
                // 清理骰子节点数组
                diceNodes.removeAll()
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupScene() {
        // 设置相机
        cameraNode.camera = SCNCamera()
        // 根据骰子数量调整相机距离
        let cameraZ = Float(diceCount)  // 骰子越多，相机越远
        cameraNode.position = SCNVector3(x: 0, y: 0, z: cameraZ)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // 创建多个骰子
        let spacing: Float = 1.5  // 骰子之间的间距
        let startX = -Float(diceCount - 1) * spacing / 2  // 计算起始位置，使骰子居中
        
        for i in 0..<diceCount {
            let diceNode = createDiceNode()
            diceNode.position = SCNVector3(startX + Float(i) * spacing, 0, 0)
            diceNodes.append(diceNode)
            scene.rootNode.addChildNode(diceNode)
        }
        
        // 添加环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 100
        scene.rootNode.addChildNode(ambientLight)
        
        // 添加定向光
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 800
        directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func createDiceNode() -> SCNNode {
        let node = SCNNode()
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        
        // 创建材质
        let materials = (1...6).map { number in
            let material = SCNMaterial()
            material.diffuse.contents = createDiceFace(number)
            material.locksAmbientWithDiffuse = true
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.8
            material.metalness.contents = 0.1
            return material
        }
        
        box.materials = materials
        node.geometry = box
        return node
    }
    
    private func createDiceFace(_ number: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 绘制白色背景
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
            
            // 设置点的颜色和大小
            UIColor.black.setFill()
            let dotSize: CGFloat = 80
            let spacing: CGFloat = 120
            let centerX: CGFloat = 256
            let centerY: CGFloat = 256
            
            // 绘制点的函数
            func drawDot(at point: CGPoint) {
                let dotRect = CGRect(
                    x: point.x - dotSize/2,
                    y: point.y - dotSize/2,
                    width: dotSize,
                    height: dotSize
                )
                ctx.addEllipse(in: dotRect)
                ctx.fillPath()
            }
            
            // 根据点数绘制不同的图案
            switch number {
            case 1:
                // 中心点
                drawDot(at: CGPoint(x: centerX, y: centerY))
                
            case 2:
                // 左上和右下
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY + spacing))
                
            case 3:
                // 左上、中心、右下
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX, y: centerY))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY + spacing))
                
            case 4:
                // 四角
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY + spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY + spacing))
                
            case 5:
                // 四角加中心
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX, y: centerY))
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY + spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY + spacing))
                
            case 6:
                // 左右两列各三个
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY))
                drawDot(at: CGPoint(x: centerX - spacing, y: centerY + spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY - spacing))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY))
                drawDot(at: CGPoint(x: centerX + spacing, y: centerY + spacing))
                
            default:
                break
            }
            
            // 添加边框
            UIColor.gray.withAlphaComponent(0.3).setStroke()
            ctx.setLineWidth(2)
            ctx.stroke(CGRect(x: 1, y: 1, width: 510, height: 510))
        }
    }
    
    private func getVisibleFaceValue() -> Int {
        // 直接返回已经确定的结果
        return results[0]
    }
    
    private func rollDice() {
        guard !isRolling else { return }
        
        isRolling = true
        showResults = false
        
        let duration: TimeInterval = 2.0
        
        // 为每个骰子创建动画
        for (index, diceNode) in diceNodes.enumerated() {
            // 第一步：随机旋转动画
            let rotations = Int.random(in: 3...5)
            let animation = CABasicAnimation(keyPath: "rotation")
            animation.duration = duration * 0.7
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // 设置随机旋转
            let randomRotation = SCNVector4(
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.pi * 2 * Float(rotations)
            )
            animation.toValue = NSValue(scnVector4: randomRotation)
            
            // 随机决定最终结果
            let finalResult = Int.random(in: 1...6)
            results[index] = finalResult
            
            // 创建最终朝向的动画
            let finalAnimation = CABasicAnimation(keyPath: "rotation")
            finalAnimation.beginTime = CACurrentMediaTime() + animation.duration
            finalAnimation.duration = duration * 0.3
            finalAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            finalAnimation.toValue = NSValue(scnVector4: rotationToShowFace(finalResult))
            finalAnimation.fillMode = .forwards
            finalAnimation.isRemovedOnCompletion = false
            
            // 添加动画
            diceNode.addAnimation(animation, forKey: "randomRotation")
            diceNode.addAnimation(finalAnimation, forKey: "finalRotation")
        }
        
        // 动画完成后的处理
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                showResults = true
                isRolling = false
            }
        }
    }
    
    private func rotationToShowFace(_ faceValue: Int) -> SCNVector4 {
        switch faceValue {
        case 4:
            return SCNVector4(0, 1, 0, Float.pi/2)
        case 2:  
            return SCNVector4(0, 1, 0, -Float.pi/2)
        case 5: 
            return SCNVector4(1, 0, 0, Float.pi/2)
        case 1:  
            return SCNVector4(0, 0, 0, 0) 
        case 6: 
            return SCNVector4(1, 0, 0, -Float.pi/2) 
        case 3:  
            return SCNVector4(0, 1, 0, Float.pi)
        default:
            return SCNVector4(0, 0, 0, 0)
        }
    }
}

// MARK: - Vector Extensions
extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x * x + y * y + z * z)
        return SCNVector3(x / length, y / length, z / length)
    }
    
    func dot(_ vector: SCNVector3) -> Float {
        return x * vector.x + y * vector.y + z * vector.z
    }
    
    func applying(transform: SCNMatrix4) -> SCNVector3 {
        let x = transform.m11 * self.x + transform.m21 * self.y + transform.m31 * self.z
        let y = transform.m12 * self.x + transform.m22 * self.y + transform.m32 * self.z
        let z = transform.m13 * self.x + transform.m23 * self.y + transform.m33 * self.z
        return SCNVector3(x, y, z)
    }
}

// MARK: - Matrix Extensions
extension SCNMatrix4 {
    func multiply(_ matrix: SCNMatrix4) -> SCNMatrix4 {
        return SCNMatrix4Mult(self, matrix)
    }
}

// MARK: - Preview
#Preview {
    Group {
        DiceRollView(diceCount: 1)  // 预览单个骰子
        DiceRollView(diceCount: 3)  // 预览三个骰子
        DiceRollView()              // 预览默认（两个骰子）
    }
} 
