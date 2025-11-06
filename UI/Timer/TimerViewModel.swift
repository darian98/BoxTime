//
//  TimerViewModel.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//
import SwiftUI
import Combine


enum Phase: Hashable {
    case work, rest
}

class TimerViewModel: ObservableObject {
    @Published var remainingSec: Int = 0
    @Published var workPhaseDuration: Int = 0
    @Published var restPhaseDuration: Int = 0
    @Published var roundCount: Int = 0
    @Published var currentRound: Int = 0
    @Published var remainingRounds: Int = 0
    
    @Published var currentExercise: Exercise?
    
    @Published var isRunning: Bool = false
    @Published var activePhase: Phase = .work
    
    private var timer: AnyCancellable?
    
    
    var currentExerciseName: String {
        "\(currentExercise?.name ?? "")"
    }
    
    var currentPhaseText: String {
        activePhase == .work ? "Work" : "Rest"
    }
    
    var currentRoundText: String {
        "Round: \(currentRound)"
    }
    
    var formattedRemaining: String {
        let minutes = remainingSec / 60
        let seconds = remainingSec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        guard !isRunning else { return }
        if remainingSec == 0 {
            remainingSec = (activePhase == .work) ? workPhaseDuration : restPhaseDuration
        }
        guard remainingSec > 0 else { return }
        currentRound += 1
        
        isRunning = true
        
        // Timer läuft jede Sekunde
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remainingSec > 0  && remainingRounds > 0 {
                    self.remainingSec -= 1
                    if self.remainingSec == 0 {
                        handlePhaseSwitch()
                    }
                } else {
                    self.pause() // bei 0 stoppen
                }
            }
    }
    
    
    func handlePhaseSwitch() {
        print("RemainingRounds: \(remainingRounds)")
        guard let exercise = currentExercise else { return }
        let rounds = exercise.rounds
        
        if remainingRounds > 0 {
            
            if activePhase == .rest {
                remainingRounds += -1
                if currentRound < rounds {
                    currentRound += 1
                }
            }
            print("RemainingRounds after decrement: \(remainingRounds)")
            
            activePhase = (activePhase == .work) ? .rest : .work
            
            print("ActivePhase changed to: \(activePhase)")
            
            let next = (activePhase == .work) ? workPhaseDuration : restPhaseDuration
            
            if next > 0 {
                remainingSec = next
            } else {
                print("Next Phase Duration < 0 -> Pause()")
                pause()
            }
        } else {
            print("Remaining Rounds < 0 -> Pause()")
            pause()
        }
        
    }
    
    func pause() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        pause()
        activePhase = .work
        remainingSec = workPhaseDuration
        remainingRounds = currentExercise?.rounds ?? roundCount
    }
    
    func setTrainingTapped() {
        reset()
        let exercise = Exercise(name: "Test", rounds: roundCount, workPhaseDuration: workPhaseDuration, restPhaseDuration: restPhaseDuration)
        self.remainingRounds = roundCount
        self.currentExercise = exercise
        self.remainingSec = workPhaseDuration
        activePhase = .work
        
    }
    
    
}
