import SwiftUI

struct MultiPlayerDecisionView: View {
    @StateObject private var decisionManager = DecisionManager()
    @State private var showingRoleSelection = true
    @State private var diceResult: Int?
    
    var body: some View {
        VStack {
            if showingRoleSelection && decisionManager.currentRole == nil {
                roleSelectionView
            } else {
                mainDecisionView
            }
        }
        .navigationTitle("多人决策")
        .alert(item: Binding(
            get: { decisionManager.connectionError.map { ConnectionError(message: $0) } },
            set: { _ in decisionManager.connectionError = nil }
        )) { error in
            Alert(
                title: Text("连接错误"),
                message: Text(error.message),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}

// MARK: - Subviews
extension MultiPlayerDecisionView {
    private var roleSelectionView: some View {
        VStack(spacing: 20) {
            Text("选择您的角色")
                .font(.title)
                .padding(.top, 30)
            
            // 连接要求提示
            ConnectionRequirementsView()
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // 发起者按钮
                Button(action: {
                    decisionManager.startAsHost()
                    showingRoleSelection = false
                }) {
                    RoleButton(
                        title: "发起决策",
                        subtitle: "创建新的决策并邀请他人加入",
                        systemImage: "person.2.circle.fill",
                        color: .blue
                    )
                }
                
                // 参与者按钮
                Button(action: {
                    decisionManager.startAsParticipant()
                    showingRoleSelection = false
                }) {
                    RoleButton(
                        title: "加入决策",
                        subtitle: "加入他人发起的决策",
                        systemImage: "person.badge.plus",
                        color: .green
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var mainDecisionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 角色状态卡片
                RoleStatusCard(role: decisionManager.currentRole)
                
                // 参与者列表卡片
                ConnectedPeersView(
                    peers: decisionManager.connectedPeers,
                    currentPeer: decisionManager.myPeerId,
                    isHost: decisionManager.isHost,
                    diceResults: decisionManager.diceResults
                )
                .padding(.vertical, 16)
                
                // 操作按钮卡片
                VStack(spacing: 16) {
                    if decisionManager.isHost {
                        HostActionView(
                            decisionManager: decisionManager,
                            diceResult: $diceResult
                        )
                    } else {
                        ParticipantActionView(
                            decisionManager: decisionManager,
                            diceResult: $diceResult
                        )
                    }
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // 退出按钮
                ExitButton(action: {
                    decisionManager.stopSearching()
                    showingRoleSelection = true
                })
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Supporting Views
private struct ConnectionRequirementsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("连接要求")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "wifi")
                        .foregroundColor(.blue)
                    Text("设备需要在同一Wi-Fi网络下")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "wave.3.right")
                        .foregroundColor(.blue)
                    Text("或开启设备的蓝牙功能")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

private struct RoleStatusCard: View {
    let role: MultipeerSessionManager.Role?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: role?.icon ?? "person.fill")
                .font(.system(size: 40))
                .foregroundColor(role == .host ? .yellow : .green)
            
            Text(role?.title ?? "")
                .font(.title2)
                .foregroundColor(.primary)
            
            Text(role?.description ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

private struct ExitButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.left.circle.fill")
                Text("退出决策")
            }
            .font(.headline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Supporting Types
private struct ConnectionError: Identifiable {
    let id = UUID()
    let message: String
}
