//
//  SettingsView.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//
import SwiftUI

struct QuickStartView: View {
    
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    
    // Formatter für "dezimal", aber ohne Nachkommastellen
    private static let secondsFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimum = 0
        f.maximumFractionDigits = 0
        return f
    }()
    
    var body: some View {
        Form {
            Section(header: Text("Work-Phase-Duration")) {
                HStack {
                    Text("Sekunden")
                    Spacer()
                    // Eingabe direkt in viewModel.durationSec (Int) mit Formatter
                    TextField("30",
                              value: $timerViewModel.workPhaseDuration,
                              formatter: Self.secondsFormatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                }
            }
            
            // Pausenphase
            Section(header: Text("Rest-Phase-Duration")) {
                HStack {
                    Text("Sekunden")
                    Spacer()
                    TextField("10",
                              value: $timerViewModel.restPhaseDuration,
                              formatter: Self.secondsFormatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                }
            }
            
            // Pausenphase
            Section(header: Text("Rounds-Count")) {
                HStack {
                    Text("Runden")
                    Spacer()
                    TextField("10",
                              value: $timerViewModel.roundCount,
                              formatter: Self.secondsFormatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                }
            }
            
            Section {
                Button {
                    timerViewModel.setTrainingTapped() // Setzt remaining = duration
                    homeViewModel.activeTab = .timer
                } label: {
                    Label("In Timer laden", systemImage: "tray.and.arrow.down.fill")
                }
                
                // Laden + direkt starten
                Button {
                    timerViewModel.setTrainingTapped()
                    timerViewModel.startTimer()             // sofort starten
                    homeViewModel.activeTab = .timer
                } label: {
                    Label("Jetzt starten", systemImage: "play.circle.fill")
                }
                .tint(.green)
            }
        }
    }
}

#Preview {
    QuickStartView(timerViewModel: TimerViewModel(), homeViewModel: HomeViewModel())
}

