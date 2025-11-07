//
//  Exercise.swift
//  BoxTime
//
//  Created by Darian Hanci on 06.11.25.
//

import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var rounds: Int
    var workPhaseDuration: Int  // in Sekunden
    var restPhaseDuration: Int  // in Sekunden
}
