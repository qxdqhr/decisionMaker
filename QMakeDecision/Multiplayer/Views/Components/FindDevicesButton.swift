import SwiftUI

struct FindDevicesButton: View {
    @Binding var showingDevicesList: Bool
    
    var body: some View {
        Button(action: {
            showingDevicesList.toggle()
        }) {
            Label("查找设备", systemImage: "antenna.radiowaves.left.and.right")
        }
    }
} 