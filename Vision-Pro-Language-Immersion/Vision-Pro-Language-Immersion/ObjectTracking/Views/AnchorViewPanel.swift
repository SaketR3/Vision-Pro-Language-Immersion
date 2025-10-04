import SwiftUI

struct AnchorPanelView: View {
    let text: String
    
    var body: some View {
        
        ZStack {
            Image("LabelBackground")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Text("Duck in Spanish is")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(text)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    
    }
}

