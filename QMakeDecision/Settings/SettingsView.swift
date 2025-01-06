import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本设置")) {
                    // 这里添加设置选项
                    Text("设置选项")
                }
            }
            .navigationTitle("设置")
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
} 