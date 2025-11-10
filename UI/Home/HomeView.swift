//
//  ContentView.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @StateObject var timerViewModel = TimerViewModel()
    
    var body: some View {
        VStack {
            
            TabView(selection: $viewModel.activeTab) {
                TimerView(viewModel: timerViewModel)
                    .tabItem { Label("Timer", systemImage: "clock") }
                    .tag(AppTab.timer)
                
                QuickStartView(timerViewModel: timerViewModel, homeViewModel: viewModel)
                    .tabItem { Label("Schnellstart", systemImage: "bolt.fill") }
                    .tag(AppTab.quickStart)
                
                TrainingListView(timerViewModel: timerViewModel, homeViewModel: viewModel)
                    .tabItem { Label("TrainingSessions", systemImage: "list.bullet.clipboard") }
                    .tag(AppTab.trainingSessions)
                
                TrainingHistoryView()
                    .tabItem { Label("Historie", systemImage: "list.bullet.rectangle") }
                    .tag(AppTab.history)
                
            }
            
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
