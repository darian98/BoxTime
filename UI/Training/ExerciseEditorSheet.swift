//
//  ExerciseEditorSheet.swift
//  BoxTime
//
//  Created by Darian Hanci on 07.11.25.
//

// ExerciseEditorSheet.swift
import SwiftUI
import RealmSwift

struct ExerciseEditorSheet: View {
    // Wir benutzen hier ein lokales, editierbares Modell und schreiben zurück beim Speichern
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var rounds: Int = 10
    @State private var work: Int = 30
    @State private var rest: Int = 10
    
    let onSave: (ExerciseEmbedded) -> Void
    
    init(initial: ExerciseEmbedded?, onSave: @escaping (ExerciseEmbedded) -> Void) {
        self.onSave = onSave
        _name = State(initialValue: initial?.name ?? "")
        _rounds = State(initialValue: initial?.rounds ?? 10)
        _work = State(initialValue: initial?.workPhaseDuration ?? 30)
        _rest = State(initialValue: initial?.restPhaseDuration ?? 10)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("z.B. Boxsack", text: $name)
                        .textInputAutocapitalization(.words)
                }
                Section("Runden & Zeiten (Sekunden)") {
                    Stepper(value: $rounds, in: 1...99) {
                        HStack { Text("Runden"); Spacer(); Text("\(rounds)") }
                    }
                    Stepper(value: $work, in: 1...3600) {
                        HStack { Text("Work"); Spacer(); Text("\(work) s") }
                    }
                    Stepper(value: $rest, in: 0...3600) {
                        HStack { Text("Rest"); Spacer(); Text("\(rest) s") }
                    }
                }
                Section {
                    HStack {
                        Label("Gesamtzeit", systemImage: "clock")
                        Spacer()
                        Text(totalText)
                    }
                }
            }
            .navigationTitle("Übung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        var e = ExerciseEmbedded()
                        e.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        e.rounds = rounds
                        e.workPhaseDuration = work
                        e.restPhaseDuration = rest
                        onSave(e)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private var totalText: String {
        let sec = (work + rest) * max(0, rounds)
        let m = sec / 60, s = sec % 60
        return String(format: "%d:%02d min", m, s)
    }
}
