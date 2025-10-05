import SwiftUI

struct AnchorPanelView: View {
    let text: String
    let translatedText: String
    
    init(text: String, translatedText: String = "") {
        self.text = text
        self.translatedText = translatedText
    }
    
    var body: some View {
        ZStack{
            
            Image("Rectangle 43").resizable().scaledToFit()
            
            VStack(spacing: 8) {
                Text("\"\(text)\" in Spanish is")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Text(translatedText)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
            
    }
}


