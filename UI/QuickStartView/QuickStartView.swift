import SwiftUI

struct QuickStartView: View {
    
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    
    // MARK: - Slider-Bindings (Int <-> Double)
    private var workDurationBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(timerViewModel.workPhaseDuration) },
            set: { newValue in
                let step: Double = 5
                let rounded = (newValue / step).rounded() * step
                timerViewModel.workPhaseDuration = Int(rounded)
            }
        )
    }

    private var restDurationBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(timerViewModel.restPhaseDuration) },
            set: { newValue in
                let step: Double = 5
                let rounded = (newValue / step).rounded() * step
                timerViewModel.restPhaseDuration = Int(rounded)
            }
        )
    }
    
    private var roundCountBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(timerViewModel.roundCount) },
            set: { timerViewModel.roundCount = Int($0) }
        )
    }
    
    // MARK: - Helper für Anzeige (Sekunden -> Minuten/Sekunden)
    private func formattedDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 && remainingSeconds == 0 {
            // z.B. 180 -> "3 Minuten"
            return minutes == 1 ? "1 Minute" : "\(minutes) Minuten"
        } else if minutes > 0 {
            // z.B. 95 -> "1 Minute 35 Sekunden"
            let minWord = (minutes == 1) ? "Minute" : "Minuten"
            let secWord = (remainingSeconds == 1) ? "Sekunde" : "Sekunden"
            return "\(minutes) \(minWord) \(remainingSeconds) \(secWord)"
        } else {
            // < 60 Sekunden
            let secWord = (seconds == 1) ? "Sekunde" : "Sekunden"
            return "\(seconds) \(secWord)"
        }
    }
    
    // MARK: - Gesamtzeit
    /// Work + Rest pro Runde * Anzahl Runden
    private var totalTrainingSeconds: Int {
        let work = max(timerViewModel.workPhaseDuration, 0)
        let rest = max(timerViewModel.restPhaseDuration, 0)
        let rounds = max(timerViewModel.roundCount, 0)
        return (work + rest) * rounds
    }
    
    private func formattedTotalDuration(_ seconds: Int) -> String {
        guard seconds > 0 else { return "0:00 Min" }
        
        // Ab 60 Minuten → Stunden-/Minuten-Format
        if seconds >= 3600 {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            
            let hourPart = hours == 1 ? "1 Std" : "\(hours) Std"
            
            if minutes > 0 {
                return "\(hourPart) \(minutes) Min"
            } else {
                return hourPart
            }
        } else {
            // Unter 60 Minuten → mm:ss Min
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d Min", minutes, remainingSeconds)
        }
    }

    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // HEADER
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Spacer()
                            Text("Schnell-Start")
                                .font(.largeTitle.bold())
                            Spacer()
                        }
                        Text("Stelle dir dein Intervall-Training in wenigen Sekunden zusammen.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // WORK-PHASE (bis 20 Minuten)
                    SettingCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Work-Phase")
                                    .font(.headline)
                                Text("Dauer der Belastung")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(formattedDuration(timerViewModel.workPhaseDuration))
                                .font(.headline.monospacedDigit())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        
                        Slider(
                            value: workDurationBinding,
                            in: 15...600,
                            step: 15
                        ) {
                            Text("Work-Dauer")
                        }
                        
                        HStack {
                            Text(formattedDuration(10))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formattedDuration(600))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // REST-PHASE (bis 5 Minuten)
                    SettingCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rest-Phase")
                                    .font(.headline)
                                Text("Dauer deiner Pause")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(formattedDuration(timerViewModel.restPhaseDuration))
                                .font(.headline.monospacedDigit())
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        
                        Slider(
                            value: restDurationBinding,
                            in: 5...300, // 5 Sek bis 5 Minuten
                            step: 5
                        ) {
                            Text("Rest-Dauer")
                        }
                        
                        HStack {
                            Text(formattedDuration(5))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formattedDuration(300))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // RUNDEN (bis 30)
                    SettingCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Runden")
                                    .font(.headline)
                                Text("Wie oft soll Work + Rest wiederholt werden?")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(timerViewModel.roundCount)")
                                .font(.headline.monospacedDigit())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        
                        Slider(
                            value: roundCountBinding,
                            in: 1...15, // bis 30 Runden
                            step: 1
                        ) {
                            Text("Rundenzahl")
                        }
                        
                        HStack {
                            Text("1 Runde")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("15 Runden")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // GESAMTDAUER
                    SettingCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Gesamtdauer")
                                    .font(.headline)
                                Spacer()
                                
                                Text(formattedTotalDuration(totalTrainingSeconds))
                                    .font(.headline.monospacedDigit())
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Aktion-Buttons
//                    VStack(spacing: 12) {
//                        Button {
//                            let success = timerViewModel.setTrainingTapped()
//                            if success {
//                                homeViewModel.activeTab = .timer
//                            }
//                        } label: {
//                            HStack {
//                                Image(systemName: "tray.and.arrow.down.fill")
//                                Text("Speichern und zum Timer")
//                            }
//                            .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        
//                        Button {
//                            let success = timerViewModel.setTrainingTapped()
//                            if success {
//                                timerViewModel.startTimer()
//                                homeViewModel.activeTab = .timer
//                            }
//                        } label: {
//                            HStack {
//                                Image(systemName: "play.circle.fill")
//                                Text("Jetzt starten")
//                            }
//                            .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .tint(.green)
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 8)
                }
            }
            
//            // Ad-Banner unten
//            if !PremiumManager.shared.hasPremium {
//                AdBannerView(
//                    adUnitID: "ca-app-pub-3940256099942544/2435281174", // Test-ID
//                    bannerType: .largeBanner
//                )
//                .frame(height: BannerType.largeBanner.height)
//                .padding(.bottom, 16)
//            }
        }
        .alert(
                "Fehler",
                isPresented: $timerViewModel.showStartTimerErrorAlert
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(timerViewModel.errorText)
            }
        // >>> Fixe Leiste am unteren Bildschirmrand (innerhalb der Safe Area)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {

                    // Werbung bleibt – fix am unteren Rand
//                    if !PremiumManager.shared.hasPremium {
//                        AdBannerView(
//                            adUnitID: "ca-app-pub-3940256099942544/2435281174",
//                            bannerType: .largeBanner
//                        )
//                        .frame(height: BannerType.largeBanner.height)
//                    }

                    // Kleinere Buttons
                    HStack(spacing: 10) {
                        Button {
                            let success = timerViewModel.setTrainingTapped()
                            if success { homeViewModel.activeTab = .timer }
                        } label: {
                            HStack {
                                Image(systemName: "tray.and.arrow.down.fill")
                                Text("Speichern")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)

                        Button {
                            let success = timerViewModel.setTrainingTapped()
                            if success {
                                timerViewModel.startTimer()
                                homeViewModel.activeTab = .timer
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Start")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.regular)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 6)
                    
                }
                .background(.ultraThinMaterial)
                .overlay(Divider(), alignment: .top)
            }

    }
}


// Kleine Helfer-View für einen sauberen Karten-Look
struct SettingCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    QuickStartView(timerViewModel: TimerViewModel(), homeViewModel: HomeViewModel())
}
