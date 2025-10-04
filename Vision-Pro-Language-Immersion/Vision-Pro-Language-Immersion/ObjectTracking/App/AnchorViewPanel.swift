import SwiftUI

struct AnchorPanelView: View {
    let text: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
