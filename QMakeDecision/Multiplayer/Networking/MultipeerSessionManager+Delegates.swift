import MultipeerConnectivity

extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, 
                   didReceiveInvitationFromPeer peerID: MCPeerID, 
                   withContext context: Data?, 
                   invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 处理接收到的邀请
    }
}

extension MultipeerSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, 
                foundPeer peerID: MCPeerID, 
                withDiscoveryInfo info: [String : String]?) {
        // 发现新的对等设备
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, 
                lostPeer peerID: MCPeerID) {
        // 失去对等设备连接
    }
} 