//
//  HomeViewModel.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//
import SwiftUI
import Combine

enum AppTab: Hashable {
    case tab1, tab2, tab3
}

class HomeViewModel: ObservableObject {
    @Published var activeTab: AppTab = .tab1
}
