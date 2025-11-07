//
//  TrainingSession.swift
//  BoxTime
//
//  Created by Darian Hanci on 06.11.25.
//

import Foundation

struct TrainingSession: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var date: Date
    var exercises: [Exercise]
}

