// TimerView.swift
import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        ZStack {
            viewModel.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Übungs-Header
                VStack(spacing: 4) {
                    
                    
                    
                    Text(viewModel.currentExerciseName)
                        .font(.title2).bold()
                        .lineLimit(1)
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
                
                // Phase & Runde
                Text(viewModel.currentPhaseText)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                Text(viewModel.currentRoundText)
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                
                // Restzeit
                Text("\(viewModel.formattedRemaining) s")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                
                // Steuerung
                HStack(spacing: 12) {
                    Button {
                        viewModel.backToPreviousExercise()
                    } label: {
                        Label("Zurück", systemImage: "backward.end.fill")
                            .font(.title3)
                            .padding()
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.hasPreviousExercise || viewModel.isRunning)
                    
                    Button {
                        viewModel.isRunning ? viewModel.pause() : viewModel.startTimer()
                    } label: {
                        Label(viewModel.isRunning ? "Stop" : "Start",
                              systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .padding()
                            .background(viewModel.isRunning ? Color.red.opacity(0.25) : Color.green.opacity(0.25))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        viewModel.skipToNextExercise()
                    } label: {
                        Label("Weiter", systemImage: "forward.end.fill")
                            .font(.title3)
                            .padding()
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.hasNextExercise || viewModel.isRunning)
                }
                
                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.title3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                .padding(.top, 6)
                
                Spacer()
                
                if !PremiumManager.shared.hasPremium {
                    AdBannerView(
                        adUnitID: "ca-app-pub-3940256099942544/2435281174", // Test-ID
                        bannerType: .banner
                    )
                    .frame(height: BannerType.banner.height)
                }
                
            }
            .padding()
        }
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel())
}
