import SwiftUI
import ARKit
import RealityKit
import UniformTypeIdentifiers

struct HomeView: View {
    @Bindable var appState: AppState
    let immersiveSpaceIdentifier: String
    
    let languages = ["English", "Nahuatl", "Français", "日本語", "Deutsch", "中文"]
    @State private var selectedLanguage: String = "English" // Keep default for initial state
    
    @State private var isOpeningImmersiveSpace = false
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Image("Group 24")
                .resizable()
                .scaledToFit()
                .padding(20)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(.black.opacity(0.25))
                )

            VStack(spacing: 20) {
                Text("Welcome Back, John!")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                VStack(spacing: 8) {
                    Text("Select Your Language")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(languages, id: \.self) { language in
                                // --- UPDATED: Conditional styling and action for language buttons ---
                                Button(action: {
                                    if language == "Nahuatl" { // Only Español is clickable
                                        withAnimation(.spring) {
                                            selectedLanguage = language
                                        }
                                    }
                                }) {
                                    Text(language)
                                        .font(.body)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .foregroundStyle(language == "Nahuatl" ? .black : .white.opacity(0.4)) // Darker text for non-Español
                                }
                                // Conditional background for the button itself
                                .background(language == "Nahuatl" ? .white : .white.opacity(0.05)) // Highlight Español, make others darker
                                .clipShape(Capsule())
                                .disabled(language != "Nahuatl") // Only Español is enabled
                            }
                        }
                        .padding(.horizontal)
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 50)
                }

                if appState.isImmersiveSpaceOpened {
                    Button(action: {
                        Task { await closeImmersiveSpaceIfNeeded() }
                    }) {
                        Text("Exit Immersion Mode")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(EdgeInsets(top: 16, leading: 25, bottom: 16, trailing: 25))
                            .frame(maxWidth: .infinity)
                    }
                    .background(.white.opacity(0.1))
                    .clipShape(Capsule())

                } else {
                    Button(action: {
                        Task {
                            isOpeningImmersiveSpace = true
                            defer { isOpeningImmersiveSpace = false }
                            
                            switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                            case .opened:
                                appState.isImmersiveSpaceOpened = true
                            default:
                                appState.isImmersiveSpaceOpened = false
                            }
                        }
                    }) {
                        Text("Immersion Mode")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(EdgeInsets(top: 16, leading: 25, bottom: 16, trailing: 25))
                            .frame(maxWidth: .infinity)
                    }
                    .background(
                        LinearGradient(
                            colors: [.blue.opacity(0.6), .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .purple.opacity(0.7), radius: 15, x: 0, y: 0)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                    )
                }
            }
            .padding(30)
            .frame(width: 380, height: 380)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 40))
            .opacity(isOpeningImmersiveSpace ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isOpeningImmersiveSpace)
        }
        .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
            handleScenePhase(newPhase)
        }
        .onChange(of: appState.providersStoppedWithError) { _, hasError in
            if hasError {
                Task { await closeImmersiveSpaceIfNeeded() }
            }
        }
        .task {
            if appState.allRequiredProvidersAreSupported {
                await appState.requestWorldSensingAuthorization()
            }
        }
        .task {
            await appState.monitorSessionEvents()
        }
    }
}

// MARK: - Helpers
private extension HomeView {
    func handleScenePhase(_ phase: ScenePhase) {
        if phase == .active {
            Task { await appState.queryWorldSensingAuthorization() }
        } else {
            Task { await closeImmersiveSpaceIfNeeded() }
        }
    }

    func closeImmersiveSpaceIfNeeded() async {
        if appState.isImmersiveSpaceOpened {
            await dismissImmersiveSpace()
            appState.didLeaveImmersiveSpace()
        }
    }
}
