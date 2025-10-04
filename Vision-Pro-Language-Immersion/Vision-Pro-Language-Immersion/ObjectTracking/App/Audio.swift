//import SwiftUI
//import AVFoundation // Required for audio playback
//
//// MARK: - DATA MODEL
//// This struct matches the JSON object returned by your Flask API.
//// Codable protocol allows it to be easily decoded from JSON data.
//struct TranslationResponse: Codable {
//    let translation: String
//    let fact: String
//    let translation_audio: String // Base64 encoded audio string
//    let fact_audio: String      // Base64 encoded audio string
//}
//
//
//
//
//
//// MARK: - VIEW MODEL
//// This class handles the app's state and logic, separating it from the UI.
//@MainActor // Ensures UI updates happen on the main thread
//class ViewModel: ObservableObject {
//    // UI State Properties
//    @Published var inputText: String = "house" // Default text for demonstration
//    @Published var translationResult: TranslationResponse?
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    // Audio Player Properties
//    private var translationPlayer: AVAudioPlayer?
//    private var factPlayer: AVAudioPlayer?
//    
//    // The URL for your Flask backend.
//    // IMPORTANT: Replace "127.0.0.1" with your computer's local network IP address
//    // if you are running this on a real device or simulator.
//    private let apiURL = "http://127.0.0.1:5000/translate-fact-audio?text="
//
//    // MARK: - Networking
//    func fetchTranslation() async {
//        guard !inputText.isEmpty else {
//            errorMessage = "Please enter a word."
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        translationResult = nil
//
//        // Create the full URL, ensuring the input text is properly encoded for a URL.
//        guard let url = URL(string: apiURL + (inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) else {
//            errorMessage = "Invalid URL."
//            isLoading = false
//            return
//        }
//
//        do {
//            // Perform the network request
//            let (data, _) = try await URLSession.shared.data(from: url)
//            
//            // Decode the JSON response into our Swift struct
//            let decodedResponse = try JSONDecoder().decode(TranslationResponse.self, from: data)
//            self.translationResult = decodedResponse
//            
//            // Prepare the audio players with the new data
//            setupAudioPlayers()
//            
//        } catch {
//            // Handle potential errors
//            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
//        }
//        
//        isLoading = false
//    }
//
//    // MARK: - Audio Handling
//    private func setupAudioPlayers() {
//        guard let result = translationResult else { return }
//
//        // Setup player for the translation audio
//        if let audioData = Data(base64Encoded: result.translation_audio) {
//            do {
//                translationPlayer = try AVAudioPlayer(data: audioData)
//                translationPlayer?.prepareToPlay()
//            } catch {
//                errorMessage = "Could not prepare translation audio."
//            }
//        }
//
//        // Setup player for the fact audio
//        if let audioData = Data(base64Encoded: result.fact_audio) {
//            do {
//                factPlayer = try AVAudioPlayer(data: audioData)
//                factPlayer?.prepareToPlay()
//            } catch {
//                errorMessage = "Could not prepare fact audio."
//            }
//        }
//    }
//
//    func playTranslationAudio() {
//        // Stop the other player to prevent overlap
//        factPlayer?.stop()
//        translationPlayer?.currentTime = 0 // Rewind to start
//        translationPlayer?.play()
//    }
//
//    func playFactAudio() {
//        // Stop the other player to prevent overlap
//        translationPlayer?.stop()
//        factPlayer?.currentTime = 0 // Rewind to start
//        factPlayer?.play()
//    }
//}
//
//// MARK: - SWIFTUI VIEW
//struct ContentView: View {
//    // @StateObject creates and manages a single instance of our ViewModel.
//    @StateObject private var viewModel = ViewModel()
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                // --- Input Section ---
//                Text("Nahuatl Translator")
//                    .font(.extraLargeTitle2)
//                    .padding(.bottom)
//                
//                TextField("Enter a word (e.g., house)", text: $viewModel.inputText)
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.horizontal)
//                
//                Button(action: {
//                    Task {
//                        await viewModel.fetchTranslation()
//                    }
//                }) {
//                    // Show a progress indicator while loading
//                    if viewModel.isLoading {
//                        ProgressView()
//                            .padding(.horizontal)
//                    } else {
//                        Label("Translate", systemImage: "globe")
//                    }
//                }
//                .disabled(viewModel.isLoading)
//                .padding()
//                
//                // --- Results Section ---
//                if let result = viewModel.translationResult {
//                    VStack(alignment: .leading, spacing: 15) {
//                        ResultCard(
//                            title: "Translation (Nahuatl)",
//                            content: result.translation,
//                            onPlay: viewModel.playTranslationAudio
//                        )
//                        ResultCard(
//                            title: "Cultural Fact",
//                            content: result.fact,
//                            onPlay: viewModel.playFactAudio
//                        )
//                    }
//                    .padding()
//                }
//                
//                // --- Error Display ---
//                if let errorMessage = viewModel.errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//                
//                Spacer() // Pushes content to the top
//            }
//            .padding(30)
//            .navigationTitle("Translator")
//        }
//    }
//}
//
//
//// MARK: - Reusable UI Component
//// A helper view to display results in a consistent card format.
//struct ResultCard: View {
//    let title: String
//    let content: String
//    let onPlay: () -> Void // A closure to be executed when the button is tapped
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.title2)
//                .foregroundStyle(.secondary)
//            
//            HStack {
//                Text(content)
//                    .font(.system(.title, design: .rounded))
//                
//                Spacer()
//                
//                Button(action: onPlay) {
//                    Image(systemName: "speaker.wave.2.fill")
//                        .font(.title)
//                }
//                .buttonStyle(.borderless) // Style for visionOS
//            }
//        }
//        .padding()
//        .background(.regularMaterial, in: .rect(cornerRadius: 20))
//    }
//}
//
//
//// MARK: - App Entry Point
//// This is where your visionOS app starts.
//@main
//struct NahuatlTranslatorApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
