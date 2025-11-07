// TimerViewModel.swift
import SwiftUI
import Combine
import RealmSwift

enum Phase: Hashable {
    case work, rest
}

class TimerViewModel: ObservableObject {
    // MARK: - Öffentliche States (UI-Bindings)
    @Published var remainingSec: Int = 0
    @Published var workPhaseDuration: Int = 0
    @Published var restPhaseDuration: Int = 0
    @Published var roundCount: Int = 0         // für Single-Exercise-Start (Legacy)
    
    @Published var currentRound: Int = 0       // 1-basiert während des Laufs
    @Published var remainingRounds: Int = 0
    
    @Published var isRunning: Bool = false
    @Published var activePhase: Phase = .work
    
    // Mehrere Übungen
    @Published private(set) var exercises: [PlainExercise] = []
    @Published private(set) var currentExerciseIndex: Int = 0
    
    // Fertig-Flag
    @Published var isFinished: Bool = false
    
    // MARK: - Intern
    private var timer: AnyCancellable?
    
    // MARK: - Abgeleitete Werte
    var backgroundColor: Color {
        activePhase == .work ? .green : .red
    }
    
    var currentExercise: PlainExercise? {
        guard exercises.indices.contains(currentExerciseIndex) else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var currentExerciseName: String {
        currentExercise?.name ?? "—"
    }
    
    var currentPhaseText: String {
        activePhase == .work ? "Work" : "Rest"
    }
    
    var currentRoundText: String {
        if let ex = currentExercise {
            return "Round: \(currentRound)/\(max(0, ex.rounds))"
        }
        return "Round: \(currentRound)"
    }
    
    var formattedRemaining: String {
        let minutes = remainingSec / 60
        let seconds = remainingSec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var hasNextExercise: Bool {
        currentExerciseIndex + 1 < exercises.count
    }
    
    var hasPreviousExercise: Bool {
        currentExerciseIndex > 0
    }
    
    // MARK: - Laden von Trainings / Übungen
    /// Komplettes Training aus Realm übernehmen
    func load(session: TrainingSessionObject) {
        let mapped: [PlainExercise] = session.exercises.map {
            PlainExercise(name: $0.name,
                          rounds: $0.rounds,
                          workPhaseDuration: $0.workPhaseDuration,
                          restPhaseDuration: $0.restPhaseDuration)
        }
        load(exercises: mapped)
    }
    
    /// Direkte Übergabe einer Übungsliste (z. B. für Tests)
    func load(exercises: [PlainExercise]) {
        pause()
        isFinished = false
        self.exercises = exercises
        self.currentExerciseIndex = 0
        configureForCurrentExercise(resetRounds: true)
    }
    
    // MARK: - Steuerung
    func startTimer() {
        guard !isRunning else { return }
        guard currentExercise != nil else { return }
        if remainingSec == 0 {
            // Falls neu oder nach einem Stop ohne Restzeit: Phase aufsetzen
            remainingSec = (activePhase == .work) ? workPhaseDuration : restPhaseDuration
        }
        guard remainingSec > 0 else { return }
        
        // Runde 1 starten, wenn noch keine Runde aktiv ist
        if currentRound == 0 && remainingRounds > 0 && activePhase == .work {
            currentRound = 1
        }
        
        isRunning = true
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                guard self.remainingSec > 0, self.remainingRounds > 0 else {
                    self.pause()
                    return
                }
                
                self.remainingSec -= 1
                if self.remainingSec == 0 {
                    self.handlePhaseSwitch()
                }
            }
    }
    
    func pause() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        pause()
        isFinished = false
        activePhase = .work
        currentRound = 0
        configureForCurrentExercise(resetRounds: true)
    }
    
    func skipToNextExercise() {
        guard hasNextExercise else { return }
        pause()
        currentExerciseIndex += 1
        configureForCurrentExercise(resetRounds: true)
    }
    
    func backToPreviousExercise() {
        guard hasPreviousExercise else { return }
        pause()
        currentExerciseIndex -= 1
        configureForCurrentExercise(resetRounds: true)
    }
    
    // Legacy: einzelnes "Test"-Exercise starten (kompatibel zu deiner SettingsView)
    func setTrainingTapped() {
        let exercise = PlainExercise(name: "Test",
                                     rounds: roundCount,
                                     workPhaseDuration: workPhaseDuration,
                                     restPhaseDuration: restPhaseDuration)
        load(exercises: [exercise])
    }
    
    // MARK: - Phasen/Runden/Übungs-Logik
    private func handlePhaseSwitch() {
        guard let ex = currentExercise else { return }
        
        if remainingRounds <= 0 {
            advanceExerciseOrFinish()
            return
        }
        
        switch activePhase {
        case .work:
            // Work -> Rest (Runde bleibt gleich)
            if restPhaseDuration > 0 {
                activePhase = .rest
                remainingSec = restPhaseDuration
            } else {
                // Kein Rest: Runde direkt beenden
                endRound(ex: ex)
            }
        case .rest:
            // Rest -> Rundenende
            endRound(ex: ex)
        }
    }
    
    private func endRound(ex: PlainExercise) {
        remainingRounds -= 1
        if remainingRounds > 0 {
            // nächste Runde derselben Übung
            activePhase = .work
            remainingSec = ex.workPhaseDuration
            currentRound = min(currentRound + 1, ex.rounds)
        } else {
            // Übung fertig
            advanceExerciseOrFinish()
        }
    }
    
    private func advanceExerciseOrFinish() {
        if hasNextExercise {
            currentExerciseIndex += 1
            configureForCurrentExercise(resetRounds: true)
        } else {
            // Training abgeschlossen
            pause()
            isFinished = true
            currentRound = 0
            remainingSec = 0
        }
    }
    
    private func configureForCurrentExercise(resetRounds: Bool) {
        guard let ex = currentExercise else {
            remainingSec = 0
            workPhaseDuration = 0
            restPhaseDuration = 0
            remainingRounds = 0
            return
        }
        
        workPhaseDuration = ex.workPhaseDuration
        restPhaseDuration = ex.restPhaseDuration
        
        if resetRounds {
            activePhase = .work
            remainingRounds = max(0, ex.rounds)
            currentRound = 0
            remainingSec = workPhaseDuration
        } else {
            // Nur Dauer aktualisieren (z. B. wenn sich was extern ändert)
            if activePhase == .work {
                remainingSec = workPhaseDuration
            } else {
                remainingSec = restPhaseDuration
            }
        }
    }
}
