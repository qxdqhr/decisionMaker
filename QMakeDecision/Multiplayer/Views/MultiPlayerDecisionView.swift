import SwiftUI

struct MultiPlayerDecisionView: View {
    @StateObject private var sessionManager = MultipeerSessionManager()
    @State private var showingDevicesList = false
    @State private var coinResult: Bool?
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(connectedPeersCount: sessionManager.connectedPeers.count)
            
            ConnectedPeersView(peers: sessionManager.connectedPeers)
            
            FindDevicesButton(showingDevicesList: $showingDevicesList)
                .sheet(isPresented: $showingDevicesList) {
                    DevicesListView(sessionManager: sessionManager)
                }
            
            if !sessionManager.connectedPeers.isEmpty {
                CoinFlipButton(coinResult: $coinResult) { result in
                    sessionManager.send(result: result)
                }
            }
            
            if let result = coinResult {
                ResultView(result: result)
            }
        }
        .padding()
    }
} 