//
//  RealmActiveStateRepo.swift
//  BoxTime
//
//  Created by Darian Hanci on 12.11.25.
//

import Foundation
import RealmSwift

enum ActiveState {
    case session(id: ObjectId)
    case exercise(PlainExercise)
    case none
}

protocol ActiveStateRepository {
    func saveActive(sessionId: ObjectId) throws
    func saveActive(exercise: PlainExercise) throws
    func loadActive() -> ActiveState
    func clearActive() throws
}

final class RealmActiveStateRepository: ActiveStateRepository {
    private let realmProvider: () throws -> Realm
    
    /// Du kannst hier auch eine spezielle Konfiguration injizieren
    init(realmProvider: @escaping () throws -> Realm = { try Realm() }) {
        self.realmProvider = realmProvider
    }
    
    func saveActive(sessionId: ObjectId) throws {
        let realm = try realmProvider()
        let obj = ActiveExerciseOrSessionObject()
        obj.id = "active"
        obj.trainingSessionId = sessionId
        obj.activeExercise = nil
        
        try realm.write {
            realm.add(obj, update: .modified)
        }
    }
    
    func saveActive(exercise: PlainExercise) throws {
        let realm = try realmProvider()
        let obj = ActiveExerciseOrSessionObject()
        obj.id = "active"
        obj.trainingSessionId = nil
        
        let emb = ExerciseEmbedded()
        emb.name = exercise.name
        emb.rounds = exercise.rounds
        emb.workPhaseDuration = exercise.workPhaseDuration
        emb.restPhaseDuration = exercise.restPhaseDuration
        obj.activeExercise = emb
        
        try realm.write {
            realm.add(obj, update: .modified)
        }
    }
    
    func loadActive() -> ActiveState {
        do {
            let realm = try realmProvider()
            guard let active = realm.object(ofType: ActiveExerciseOrSessionObject.self,
                                            forPrimaryKey: "active") else {
                return .none
            }
            
            if let id = active.trainingSessionId {
                return .session(id: id)
            }
            if let activeExercise = active.activeExercise {
                let plain = PlainExercise(name: activeExercise.name,
                                          rounds: activeExercise.rounds,
                                          workPhaseDuration: activeExercise.workPhaseDuration,
                                          restPhaseDuration: activeExercise.restPhaseDuration)
                return .exercise(plain)
            }
            return .none
        } catch {
            print("loadActive() Realm-Fehler: \(error)")
            return .none
        }
    }
    
    func clearActive() throws {
        let realm = try realmProvider()
        if let active = realm.object(ofType: ActiveExerciseOrSessionObject.self, forPrimaryKey: "active") {
            try realm.write {
                realm.delete(active)
            }
        }
    }
}
