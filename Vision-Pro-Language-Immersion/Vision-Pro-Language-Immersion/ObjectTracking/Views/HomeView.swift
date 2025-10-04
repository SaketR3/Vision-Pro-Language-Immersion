import SwiftUI
import ARKit
import RealityKit
import UniformTypeIdentifiers

struct HomeView: View {
    @Bindable var appState: AppState
    let immersiveSpaceIdentifier: String
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            // Background image
            Image("BackgroundImage") // <-- Replace with your asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 20) {
                Spacer()
                
                if appState.canEnterImmersiveSpace {
                    VStack(spacing: 16) {
                        Image(systemName: "arkit")
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                        
                        Text("Object Tracking")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Use your Vision Pro to detect and track 3D objects in your environment.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 40)
                    }
                } else {
                    InfoLabel(appState: appState)
                        .padding(.horizontal, 30)
                        .frame(minWidth: 400, minHeight: 300)
                        .fixedSize()
                }
                
                Spacer()
                
                // Toolbar at the bottom
                VStack(spacing: 12) {
                    if appState.canEnterImmersiveSpace {
                        if !appState.isImmersiveSpaceOpened {
                            Button("Start Tracking Objects") {
                                Task {
                                    switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                                    case .opened: break
                                    case .error:
                                        print("Error opening immersive space \(immersiveSpaceIdentifier)")
                                    case .userCancelled:
                                        print("User cancelled immersive space \(immersiveSpaceIdentifier)")
                                    @unknown default: break
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .padding(.bottom, 8)
                        } else {
                            Button("Stop Tracking") {
                                Task {
                                    await dismissImmersiveSpace()
                                    appState.didLeaveImmersiveSpace()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Text(appState.isImmersiveSpaceOpened
                             ? "This leaves the immersive space."
                             : "This enters an immersive space, hiding all other apps.")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
                .padding(.bottom, 30)
            }
            .frame(minWidth: 400, minHeight: 400)
        }
        .onChange(of: scenePhase, initial: true) {
            handleScenePhase(scenePhase)
        }
        .onChange(of: appState.providersStoppedWithError) { _, hasError in
            if hasError {
                closeImmersiveSpaceIfNeeded()
                appState.providersStoppedWithError = false
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
        print("HomeView scene phase: \(phase)")
        if phase == .active {
            Task { await appState.queryWorldSensingAuthorization() }
        } else {
            closeImmersiveSpaceIfNeeded()
        }
    }
    
    func closeImmersiveSpaceIfNeeded() {
        if appState.isImmersiveSpaceOpened {
            Task {
                await dismissImmersiveSpace()
                appState.didLeaveImmersiveSpace()
            }
        }
    }
}

