import SwiftUI
import MultipeerConnectivity

struct ConnectedPeersView: View {
    let peers: [MCPeerID]
    let currentPeer: MCPeerID
    let isHost: Bool
    let diceResults: [String: Int]
    
    var allPeers: [MCPeerID] {
        var result = [currentPeer]  // 添加当前设备
        result.append(contentsOf: peers)  // 添加其他连接的设备
        return result
    }
    
    private func formatDeviceName(_ name: String) -> String {
        // 移除设备名称中的唯一标识符部分
        if let index = name.firstIndex(of: "#") {
            return String(name[..<index])
        }
        return name
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                Text("决策参与者")
                    .font(.headline)
                Spacer()
                Text("\(allPeers.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 8)
            
            if allPeers.count <= 1 {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("等待其他设备连接...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(allPeers, id: \.self) { peer in
                            let isCurrentDevice = peer.displayName == currentPeer.displayName
                            let isHostDevice = isHost && isCurrentDevice || !isHost && !isCurrentDevice
                            
                            HStack(spacing: 8) {
                                // 用户图标
                                Image(systemName: isHostDevice ? "crown.fill" : "person.fill")
                                    .foregroundColor(isHostDevice ? .yellow : .green)
                                    .frame(width: 24)
                                
                                // 用户名和标签
                                HStack(spacing: 6) {
                                    Text(formatDeviceName(peer.displayName))
                                        .font(.body)
                                    
                                    if isCurrentDevice {
                                        Text("(我)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if isHostDevice {
                                        Text("发起者")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(4)
                                    }
                                }
                                
                                Spacer()
                                
                                // 骰子结果
                                if let diceValue = diceResults[peer.displayName] {
                                    HStack(spacing: 4) {
                                        Image(systemName: "dice.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 16)
                                        Text("\(diceValue)")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .frame(width: 20, alignment: .center)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                } else {
                                    // 占位，保持对齐
                                    HStack(spacing: 4) {
                                        Image(systemName: "dice")
                                            .foregroundColor(.secondary)
                                            .frame(width: 16)
                                        Text("-")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .frame(width: 20, alignment: .center)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                    .opacity(0.5)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 160)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 