import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    private let ringSize: CGFloat = 320        // Größerer Ring
    private let ringLineWidth: CGFloat = 22    // Etwas dicker für Premium-Look
    
    var body: some View {
        ZStack {
            viewModel.backgroundColor
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 24) {
                // Übungs-Header
                VStack(spacing: 4) {
                    if let activeTrainingSession = viewModel.activeTrainingSession {
                        Text(activeTrainingSession.title)
                            .font(.title2.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    Text(viewModel.currentExerciseName)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if let ex = viewModel.currentExercise {
                        Text("\(viewModel.currentExerciseIndex + 1)/\(viewModel.exercises.count) · \(ex.rounds)x")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if viewModel.isFinished {
                        Text("Training abgeschlossen 🎉")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Kein Training geladen")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.center)
                
                // === PROGRESS-RING FÜR AKTUELLE PHASE (Work / Rest) ===
                ZStack {
                    // Hintergrundring
                    Circle()
                        .stroke(
                            Color.white.opacity(0.12),
                            style: StrokeStyle(lineWidth: ringLineWidth)
                        )
                        .shadow(radius: 6)
                    
                    // Fortschrittsring (smooth animiert über remainingSec)
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.currentPhaseProgress))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.95),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.95)
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90)) // Start oben
                        .animation(.linear(duration: 0.95), value: viewModel.remainingSec)
                    
                    // Inhalte im Kreis: Phase, Runde, Restzeit
                    VStack(spacing: 10) {
                        Text(viewModel.currentPhaseText)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .textCase(.uppercase)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(viewModel.currentRoundText)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(viewModel.formattedRemaining) s")
                            .font(.system(size: 54, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: ringSize, height: ringSize)
                .padding(.vertical, 4)
                
                Spacer()
                // Steuerung
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Button {
                            viewModel.backToPreviousExercise()
                        } label: {
                            Label("Zurück", systemImage: "backward.end.fill")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(Color.black.opacity(0.18))
                                .cornerRadius(12)
                        }
                        .disabled(!viewModel.hasPreviousExercise || viewModel.isRunning)
                        .opacity((!viewModel.hasPreviousExercise || viewModel.isRunning) ? 0.5 : 1)
                        
                        Button {
                            viewModel.isRunning ? viewModel.pause() : viewModel.startTimer()
                        } label: {
                            Label(viewModel.isRunning ? "Pause" : "Start",
                                  systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background(
                                    (viewModel.isRunning ? Color.red : Color.green)
                                        .opacity(0.28)
                                )
                                .cornerRadius(16)
                                .shadow(radius: 4, y: 2)
                        }
                        
                        Button {
                            viewModel.skipToNextExercise()
                        } label: {
                            Label("Weiter", systemImage: "forward.end.fill")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(Color.black.opacity(0.18))
                                .cornerRadius(12)
                        }
                        .disabled(!viewModel.hasNextExercise || viewModel.isRunning)
                        .opacity((!viewModel.hasNextExercise || viewModel.isRunning) ? 0.5 : 1)
                    }
                    
                    // Reset unten etwas dezenter
                    Button {
                        viewModel.reset()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.25))
                            .cornerRadius(12)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 4)
                
                Spacer()
                
                if !PremiumManager.shared.hasPremium {
                    AdBannerView(
                        adUnitID: "ca-app-pub-3940256099942544/2435281174", // Test-ID
                        bannerType: .banner
                    )
                    .frame(height: BannerType.banner.height)
                    .padding(.bottom, LayoutHelper.adBottomPadding())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .safeAreaPadding(.top, 20)
        }
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel())
}
