import SwiftUI
import MultipeerConnectivity

struct DevicesListView: View {
    @ObservedObject var sessionManager: MultipeerSessionManager
    
    var body: some View {
        List {
            ForEach(sessionManager.connectedPeers, id: \.self) { peer in
                Text(peer.displayName)
            }
        }
    }
} 