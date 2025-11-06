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
                
                SettingsView(timerViewModel: timerViewModel)
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .tag(AppTab.tab2)
                
            }
            
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
