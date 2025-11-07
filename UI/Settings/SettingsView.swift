//
//  SettingsView.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//
import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var timerViewModel: TimerViewModel
    
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
                } label: {
                    Label("Auf neue Dauer zurücksetzen", systemImage: "arrow.uturn.backward")
                }
            }
        }
    }
}

#Preview {
    SettingsView(timerViewModel: TimerViewModel())
}

