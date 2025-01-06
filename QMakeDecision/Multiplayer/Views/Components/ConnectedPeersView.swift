import SwiftUI
import MultipeerConnectivity

struct ConnectedPeersView: View {
    let peers: [MCPeerID]
    
    var body: some View {
        Group {
            if peers.isEmpty {
                Text("等待其他设备连接...")
                    .foregroundColor(.secondary)
            } else {
                Text("已连接设备: \(peers.count)")
                ForEach(peers, id: \.self) { peer in
                    Text(peer.displayName)
                }
            }
        }
    }
} 