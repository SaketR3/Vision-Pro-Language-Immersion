import SwiftUI

struct AnchorPanelView: View {
    let text: String
    let translatedText: String
    
    init(text: String, translatedText: String = "", backgroundImageName: String? = nil) {
        self.text = text
        self.translatedText = translatedText
    }
    var body: some View {
        VStack {
            ZStack{
                Image("Rectangle 43")
                    .resizable()
                    .scaledToFill()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                HStack{
                    Text("\"\(text)\" in Nahuatl is")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Text(translatedText)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                    }.multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }
            
            
//                HStack{
//                    Spacer()
//                    Image("LongerView")
//                        .resizable()
//                        .scaledToFill()
//                        .allowsHitTesting(false)
//                        .accessibilityHidden(true)
//                    Image("ShortView")
//                        .resizable()
//                        .scaledToFill()
//                        .allowsHitTesting(false)
//                        .accessibilityHidden(true)
//                    Image("CloseButtonLabel")
//                        .resizable()
//                        .scaledToFill()
//                        .allowsHitTesting(false)
//                        .accessibilityHidden(true)
//                }
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    
}
