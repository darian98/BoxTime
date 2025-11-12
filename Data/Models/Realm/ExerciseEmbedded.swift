//
//  ExerciseEmbedded.swift
//  BoxTime
//
//  Created by Darian Hanci on 07.11.25.
//

import Foundation
import RealmSwift

// Eingebettetes Exercise, gehört zu genau einer Session
class ExerciseEmbedded: EmbeddedObject {
    @Persisted var name: String = ""
    @Persisted var rounds: Int = 0
    @Persisted var workPhaseDuration: Int = 0    // Sek.
    @Persisted var restPhaseDuration: Int = 0    // Sek.
}

// TrainingSession als Hauptobjekt
class TrainingSessionObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var date: Date = Date()
    @Persisted var exercises: List<ExerciseEmbedded>
}

// Helper: Gesamtzeit pro Exercise & Session
extension ExerciseEmbedded {
    var totalSeconds: Int { (workPhaseDuration + restPhaseDuration) * max(0, rounds) }
}

extension TrainingSessionObject {
    var totalSeconds: Int { exercises.reduce(0) { $0 + $1.totalSeconds } }
    var exerciseCountText: String { "\(exercises.count) Übung\(exercises.count == 1 ? "" : "en")" }
    var totalTimeText: String {
        let sec = totalSeconds
        let m = sec / 60, s = sec % 60
        return String(format: "%d:%02d min", m, s)
    }
}

struct PlainExercise: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var rounds: Int
    var workPhaseDuration: Int
    var restPhaseDuration: Int
}

class ActiveExerciseOrSessionObject: Object {
    @Persisted(primaryKey: true) var id: String = "active"
    @Persisted var trainingSessionId: ObjectId?
    @Persisted var activeExercise: ExerciseEmbedded?     // <- genau EINE Exercise
}
