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
    
    
    @Published var isRunning: Bool = false
    @Published var activePhase: Phase = .work
    
    private var timer: AnyCancellable?
    
    
    var formattedRemaining: String {
        let minutes = remainingSec / 60
        let seconds = remainingSec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
  
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        
        // Timer läuft jede Sekunde
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remainingSec > 0 {
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
        activePhase = (activePhase == .work) ? .rest : .work
        
        let next = (activePhase == .work) ? workPhaseDuration : restPhaseDuration
        
        if next > 0 {
            remainingSec = next
        } else {
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
        remainingSec = workPhaseDuration
    }
    
    
}
