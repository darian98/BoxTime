//
//  HomeViewModel.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//
import SwiftUI
import Combine

enum AppTab: Hashable {
    case timer, quickStart, trainingSessions, history
}

class HomeViewModel: ObservableObject {
    @Published var activeTab: AppTab = .timer
}
