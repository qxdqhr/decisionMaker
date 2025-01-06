import MultipeerConnectivity

class MultipeerSessionManager: NSObject, ObservableObject {
    private let serviceType = "q-decision"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    @Published var connectedPeers: [MCPeerID] = []
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId,
                                                    discoveryInfo: nil,
                                                    serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId,
                                              serviceType: serviceType)
        super.init()
        
        setupMultipeer()
    }
    
    private func setupMultipeer() {
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    func send(result: Bool) {
        MultiPlayerActivityManager.shared.updateVotingStatus(result: result)
    }
    
    func startVoting() {
        MultiPlayerActivityManager.shared.startActivity(connectedPeers: connectedPeers.count)
    }
    
    deinit {
        MultiPlayerActivityManager.shared.endActivity()
    }
} 