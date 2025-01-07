import Foundation
import MultipeerConnectivity
import Combine

@MainActor
class DecisionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentRole: MultipeerSessionManager.Role?
    @Published var connectedPeers: [MCPeerID] = []
    @Published var diceResults: [String: Int] = [:]
    @Published var isSearching = false
    @Published var canRollDice = false
    @Published var hasRolledDice = false
    @Published var isDecisionCompleted = false
    @Published var connectionError: String?
    
    // MARK: - Private Properties
    private let sessionManager: MultipeerSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(sessionManager: MultipeerSessionManager = MultipeerSessionManager()) {
        self.sessionManager = sessionManager
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        sessionManager.$currentRole
            .assign(to: \.currentRole, on: self)
            .store(in: &cancellables)
        
        sessionManager.$connectedPeers
            .assign(to: \.connectedPeers, on: self)
            .store(in: &cancellables)
        
        sessionManager.$diceResults
            .assign(to: \.diceResults, on: self)
            .store(in: &cancellables)
        
        sessionManager.$isSearching
            .assign(to: \.isSearching, on: self)
            .store(in: &cancellables)
        
        sessionManager.$canRollDice
            .assign(to: \.canRollDice, on: self)
            .store(in: &cancellables)
        
        sessionManager.$hasRolledDice
            .assign(to: \.hasRolledDice, on: self)
            .store(in: &cancellables)
        
        sessionManager.$isDecisionCompleted
            .assign(to: \.isDecisionCompleted, on: self)
            .store(in: &cancellables)
        
        sessionManager.$connectionError
            .assign(to: \.connectionError, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func startAsHost() {
        sessionManager.startAsHost()
    }
    
    func startAsParticipant() {
        sessionManager.startAsParticipant()
    }
    
    func startVoting() {
        sessionManager.startVoting()
    }
    
    func sendDiceResult(_ value: Int) {
        sessionManager.sendDiceResult(value)
    }
    
    func resetDecision() {
        sessionManager.resetDecision()
    }
    
    func stopSearching() {
        sessionManager.stopSearching()
    }
    
    // MARK: - Computed Properties
    var myPeerId: MCPeerID {
        sessionManager.myPeerId
    }
    
    var isHost: Bool {
        currentRole == .host
    }
    
    var canStartDecision: Bool {
        isHost && !connectedPeers.isEmpty && !canRollDice
    }
    
    var shouldShowDiceButton: Bool {
        canRollDice && !hasRolledDice
    }
} 
