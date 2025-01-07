import MultipeerConnectivity

class MultipeerSessionManager: NSObject, ObservableObject {
    enum Role {
        case host    // 决策发起者
        case participant    // 决策参与者
        
        var title: String {
            switch self {
            case .host:
                return "决策发起者"
            case .participant:
                return "决策参与者"
            }
        }
        
        var description: String {
            switch self {
            case .host:
                return "您可以控制决策的开始和结束"
            case .participant:
                return "等待发起者开始决策"
            }
        }
        
        var icon: String {
            switch self {
            case .host:
                return "crown.fill"
            case .participant:
                return "person.fill"
            }
        }
    }
    
    // 添加消息类型枚举
    private enum MessageType: String, Codable {
        case startDecision
        case diceResult
    }
    
    // 添加骰子结果结构
    private struct DiceResult: Codable {
        let value: Int
        let fromPeer: String
    }
    
    // 添加消息结构
    private struct Message: Codable {
        let type: MessageType
        let data: Data?
    }
    
    private let serviceType = "qm-decision"
    private let deviceId = UUID().uuidString.prefix(4)
    let myPeerId: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private var sessions: Set<MCSession> = []
    private var session: MCSession?
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var currentRole: Role?
    @Published var isSearching = false
    @Published var canRollDice = false  // 修改为骰子控制
    @Published var diceResults: [String: Int] = [:]  // 存储每个用户的骰子结果
    @Published var hasRolledDice = false  // 是否已经投过骰子
    @Published var isDecisionCompleted: Bool = false // 是否所有人都完成决策
    @Published var connectionError: String? = nil  // 添加错误提示状态
    
    override init() {
        // 创建包含唯一标识符的设备名称
        let deviceName = "\(UIDevice.current.name)#\(deviceId)"
        myPeerId = MCPeerID(displayName: deviceName)
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId,
                                                    discoveryInfo: nil,
                                                    serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId,
                                              serviceType: serviceType)
        super.init()
        
        setupMultipeer()
        print("初始化 MultipeerSessionManager，设备名称: \(deviceName)")
    }
    
    private func setupMultipeer() {
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
    
    func sendData(_ data: Data) {
        guard let session = session else {
            print("发送数据失败: session 不存在")
            return
        }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("数据发送成功，发送给: \(session.connectedPeers.map { $0.displayName })")
        } catch {
            print("发送数据失败: \(error.localizedDescription)")
        }
    }
    
    func sendDiceResult(_ value: Int) {
        guard !hasRolledDice else { return }  // 确保只能投一次骰子
        
        let result = DiceResult(value: value, fromPeer: myPeerId.displayName)
        if let resultData = try? JSONEncoder().encode(result) {
            let message = Message(type: .diceResult, data: resultData)
            if let data = try? JSONEncoder().encode(message) {
                sendData(data)
                // 更新自己的结果
                DispatchQueue.main.async {
                    self.diceResults[self.myPeerId.displayName] = value
                    self.hasRolledDice = true
                    self.checkDecisionCompletion()
                }
            }
        }
    }
    
    func startVoting() {
        guard let session = session else { return }
        
        // 重置所有状态
        diceResults.removeAll()
        hasRolledDice = false
        canRollDice = true
        isDecisionCompleted = false
        
        // 创建开始决策的消息
        let message = Message(type: .startDecision, data: nil)
        if let data = try? JSONEncoder().encode(message) {
            // 发送给所有连接的设备
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    func startAsHost() {
        // 先停止之前的所有连接
        stopSearching()
        
        print("开始作为主持人...")
        
        // 确保先设置角色
        self.currentRole = .host
        self.isSearching = true
        
        // 主持人创建新的 session
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        print("主持人 session 已创建，delegate: \(session?.delegate != nil ? "已设置" : "未设置")")
        
        // 立即开始广播
        self.serviceAdvertiser.startAdvertisingPeer()
        print("主持人开始广播... 当前角色：\(String(describing: currentRole))")
    }
    
    func startAsParticipant() {
        // 先停止之前的所有连接
        stopSearching()
        
        print("开始作为参与者...")
        
        // 确保先设置角色
        self.currentRole = .participant
        self.isSearching = true
        
        // 参与者创建新的 session
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        print("参与者 session 已创建，delegate: \(session?.delegate != nil ? "已设置" : "未设置")")
        
        // 立即开始浏览
        self.serviceBrowser.startBrowsingForPeers()
        print("参与者开始搜索... 当前角色：\(String(describing: currentRole))")
    }
    
    func stopSearching() {
        print("停止搜索... 当前角色：\(String(describing: currentRole))")
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        session?.disconnect()
        session = nil
        isSearching = false
        currentRole = nil
        canRollDice = false
        hasRolledDice = false
        isDecisionCompleted = false
        diceResults.removeAll()
        connectedPeers.removeAll()
        connectionError = nil  // 清除错误提示
        print("搜索已停止，角色已重置")
    }
    
    deinit {
       
    }
    
    // 检查是否所有人都完成了决策
    private func checkDecisionCompletion() {
        let totalParticipants = connectedPeers.count + 1 // 包括自己
        let completedParticipants = diceResults.count
        
        isDecisionCompleted = completedParticipants == totalParticipants
    }
    
    func resetDecision() {
        // 重置决策状态
        diceResults.removeAll()
        hasRolledDice = false
        canRollDice = true
        isDecisionCompleted = false
        
        // 发送重置消息给所有参与者
        let message = Message(type: .startDecision, data: nil)
        if let data = try? JSONEncoder().encode(message) {
            sendData(data)
        }
    }
    
    func exitDecision() {
        stopSearching()
    }
}

extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        if let err = error as NSError? {
            print("广播启动失败: \(err.localizedDescription)")
            
            DispatchQueue.main.async {
                self.connectionError = "无法广播设备，请确保：\n1. 已开启Wi-Fi或蓝牙\n2. 已授予应用相关权限"
            }
            return
        }
        
        let retryDelay = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            if self.currentRole == .host && self.isSearching {
                print("尝试重新启动广播...")
                self.connectionError = nil  // 清除错误提示
                self.serviceAdvertiser.startAdvertisingPeer()
            }
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("收到来自 \(peerID.displayName) 的邀请")
        print("当前角色：\(String(describing: currentRole))")
        
        guard let session = session else {
            print("警告：session 为空，无法接受邀请")
            invitationHandler(false, nil)
            return
        }
        
        guard currentRole == .host else {
            print("警告：当前不是主持人角色，拒绝邀请")
            invitationHandler(false, nil)
            return
        }
        
        // 在主线程处理邀请
        DispatchQueue.main.async {
            print("准备接受来自 \(peerID.displayName) 的邀请")
            invitationHandler(true, session)
            print("已接受来自 \(peerID.displayName) 的邀请")
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("发现设备：\(peerID.displayName)")
        print("当前角色：\(String(describing: currentRole))")
        
        // 只有参与者会搜索并发送邀请
        guard let session = session else {
            print("session 为空")
            return
        }
        
        guard let role = currentRole else {
            print("currentRole 为空")
            return
        }
        
        guard role == .participant else {
            print("当前不是参与者角色")
            return
        }
        
        print("准备向设备 \(peerID.displayName) 发送邀请")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        print("已发送邀请给设备 \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.connectedPeers.removeAll { $0 == peerID }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("浏览启动失败: \(error.localizedDescription)")
        if let error = error as NSError? {
            print("错误域: \(error.domain)")
            print("错误代码: \(error.code)")
            print("错误信息: \(error.userInfo)")
            
            DispatchQueue.main.async {
                self.connectionError = "无法搜索其他设备，请确保：\n1. 已开启Wi-Fi或蓝牙\n2. 已授予应用相关权限"
            }
        }
        
        // 使用指数退避策略进行重试
        let retryDelay = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            if self.currentRole == .participant && self.isSearching {
                print("尝试重新启动浏览...")
                self.connectionError = nil  // 清除错误提示
                self.serviceBrowser.startBrowsingForPeers()
            }
        }
    }
}

extension MultipeerSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("收到 session 状态变化")
        print("peer: \(peerID.displayName)")
        print("当前角色：\(String(describing: currentRole))")
        
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("设备 \(peerID.displayName) 已连接")
                print("当前连接的设备数：\(session.connectedPeers.count)")
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                    // 清除该用户的旧结果
                    self.diceResults.removeValue(forKey: peerID.displayName)
                    // 重新检查决策完成状态
                    self.checkDecisionCompletion()
                    print("已更新连接设备列表，当前设备数：\(self.connectedPeers.count)")
                }
            case .notConnected:
                print("设备 \(peerID.displayName) 断开连接")
                self.connectedPeers.removeAll { $0 == peerID }
                // 清除断开连接用户的决策结果
                self.diceResults.removeValue(forKey: peerID.displayName)
                // 重新检查决策完成状态
                self.checkDecisionCompletion()
                print("已更新连接设备列表，当前设备数：\(self.connectedPeers.count)")
            case .connecting:
                print("正在与设备 \(peerID.displayName) 建立连接...")
            @unknown default:
                print("未知的连接状态")
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(Message.self, from: data) else { return }
        
        DispatchQueue.main.async {
            switch message.type {
            case .startDecision:
                self.diceResults.removeAll()
                self.hasRolledDice = false
                self.canRollDice = true
                self.isDecisionCompleted = false
            case .diceResult:
                if let resultData = message.data,
                   let result = try? JSONDecoder().decode(DiceResult.self, from: resultData) {
                    self.diceResults[result.fromPeer] = result.value
                    self.checkDecisionCompletion()
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
} 
