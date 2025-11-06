//
//  TimerView.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//
import SwiftUI

struct TimerView: View {
    
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        ZStack {
            viewModel.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text(viewModel.currentRoundText)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                Text(viewModel.currentPhaseText)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                
                Text("\(viewModel.formattedRemaining) s")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                
                HStack(spacing: 20) {
                    
                    startTimerButtonView
                    
                    resetTimerButtonView
                }
            }
            .padding()
        }
    }
    
    private var startTimerButtonView: some View {
        Button {
            viewModel.isRunning ? viewModel.pause() : viewModel.startTimer()
        } label: {
            Label(viewModel.isRunning ? "Stop" : "Start", systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                .font(.title2)
                .padding()
                .background(viewModel.isRunning ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                .cornerRadius(12)
        }
    }
    
    private var resetTimerButtonView: some View {
        Button {
            viewModel.reset()
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .font(.title2)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
        }

    }
}

#Preview {
    TimerView(viewModel: TimerViewModel())
}

