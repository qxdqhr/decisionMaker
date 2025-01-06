import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        #if os(iOS)
        // iOS 和 iPadOS 使用底部 TabView
        TabView(selection: $selectedTab) {
            DecisionView()
                .tabItem {
                    Image(systemName: "dice")
                    Text("随机决策")
                }
                .tag(0)
            
            MultiPlayerDecisionView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("多人决策")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(2)
        }
        #else
        // macOS 使用侧边栏导航
        NavigationView {
            List {
                NavigationLink(
                    destination: DecisionView(),
                    tag: 0,
                    selection: $selectedTab
                ) {
                    Label("随机决策", systemImage: "dice")
                }
                
                NavigationLink(
                    destination: MultiPlayerDecisionView(),
                    tag: 1,
                    selection: $selectedTab
                ) {
                    Label("多人决策", systemImage: "person.3")
                }
                
                NavigationLink(
                    destination: SettingsView(),
                    tag: 2,
                    selection: $selectedTab
                ) {
                    Label("设置", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            DecisionView()
        }
        #endif
    }
} 
