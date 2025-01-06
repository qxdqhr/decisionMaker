import SwiftUI

struct ResultView: View {
    let result: Bool
    
    var body: some View {
        Text(result ? "正面" : "反面")
            .font(.largeTitle)
            .padding()
    }
} 