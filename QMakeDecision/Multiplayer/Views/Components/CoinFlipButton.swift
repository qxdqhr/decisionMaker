import SwiftUI

struct CoinFlipButton: View {
    @Binding var coinResult: Bool?
    let onFlip: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            let result = Bool.random()
            coinResult = result
            onFlip(result)
        }) {
            Text("抛硬币")
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
} 