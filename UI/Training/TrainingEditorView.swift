import SwiftUI
import RealmSwift

struct TrainingEditorView: View {
    /// nil => neues Training, sonst Bearbeitung einer bestehenden Session
    let originalSession: TrainingSessionObject?
    
    @Environment(\.dismiss) private var dismiss
    
    // Lokale, NICHT direkt mit Realm verbundene States
    @State private var title: String
    @State private var date: Date
    @State private var exercises: [ExerciseEmbedded]
    
    private enum ExerciseSheetMode: Identifiable {
        case new
        case edit(index: Int)
        
        var id: String {
            switch self {
            case .new: return "new"
            case .edit(let index): return "edit_\(index)"
            }
        }
    }
    
    @State private var sheetMode: ExerciseSheetMode?
    
    // Init für "Neu"
    init() {
        self.originalSession = nil
        _title     = State(initialValue: "")
        _date      = State(initialValue: Date())
        _exercises = State(initialValue: [])
    }
    
    // Init für "Bearbeiten"
    init(session: TrainingSessionObject) {
        self.originalSession = session
        _title = State(initialValue: session.title)
        _date  = State(initialValue: session.date)
        
        // Unmanaged Kopien der Embedded Exercises erzeugen
        let copies: [ExerciseEmbedded] = session.exercises.map { ex in
            let copy = ExerciseEmbedded()
            copy.name = ex.name
            copy.rounds = ex.rounds
            copy.workPhaseDuration = ex.workPhaseDuration
            copy.restPhaseDuration = ex.restPhaseDuration
            return copy
        }
        _exercises = State(initialValue: copies)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Allgemein") {
                    TextField("Titel", text: $title)
                        .textInputAutocapitalization(.words)
                    DatePicker("Datum", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    if exercises.isEmpty {
                        ContentUnavailableView(
                            "Noch keine Übungen",
                            systemImage: "dumbbell",
                            description: Text("Füge unten eine Übung hinzu.")
                        )
                    } else {
                        ForEach(Array(exercises.enumerated()), id: \.offset) { index, ex in
                            Button {
                                sheetMode = .edit(index: index)
                            } label: {
                                ExerciseRow(ex: ex)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    removeExercise(at: index)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    Button {
                        sheetMode = .new
                    } label: {
                        Label("Übung hinzufügen", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Übungen")
                } footer: {
                    HStack {
                        Label("Gesamtzeit: \(totalTimeText)", systemImage: "clock")
                        Spacer()
                        Label("\(exercises.count) Üb.", systemImage: "list.bullet")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(originalSession == nil ? "Training erstellen" : "Training bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { handleCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { handleSave() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(item: $sheetMode) { mode in
                let initial: ExerciseEmbedded? = {
                    switch mode {
                    case .new:
                        return nil
                    case .edit(let idx):
                        return exercises.indices.contains(idx) ? exercises[idx] : nil
                    }
                }()
                
                ExerciseEditorSheet(
                    initial: initial,
                    onSave: { updated in
                        applyExercise(updated, mode: mode)
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var totalTimeText: String {
        let totalSeconds = exercises.reduce(0) { $0 + $1.totalSeconds }
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private func removeExercise(at index: Int) {
        guard exercises.indices.contains(index) else { return }
        exercises.remove(at: index)
    }
    
    private func applyExercise(_ newValue: ExerciseEmbedded, mode: ExerciseSheetMode) {
        switch mode {
        case .new:
            exercises.append(newValue)
        case .edit(let idx):
            guard exercises.indices.contains(idx) else { return }
            exercises[idx] = newValue
        }
    }
    private func handleCancel() {
        // Nichts zurückschreiben → alle Änderungen verworfen
        dismiss()
    }
    private func handleSave() {
        do {
            let realm = try Realm()
            try realm.write {
                if let original = originalSession {
                    // Bestehendes Training updaten
                    let target: TrainingSessionObject
                    if original.isFrozen, let thawed = original.thaw() {
                        target = thawed
                    } else {
                        target = original
                    }
                    
                    target.title = title
                    target.date  = date
                    target.exercises.removeAll()
                    
                    for draft in exercises {
                        let ex = ExerciseEmbedded()
                        ex.name = draft.name
                        ex.rounds = draft.rounds
                        ex.workPhaseDuration = draft.workPhaseDuration
                        ex.restPhaseDuration = draft.restPhaseDuration
                        target.exercises.append(ex)
                    }
                    
                } else {
                    // Neues Training anlegen
                    let new = TrainingSessionObject()
                    new.title = title
                    new.date  = date
                    
                    for draft in exercises {
                        let ex = ExerciseEmbedded()
                        ex.name = draft.name
                        ex.rounds = draft.rounds
                        ex.workPhaseDuration = draft.workPhaseDuration
                        ex.restPhaseDuration = draft.restPhaseDuration
                        new.exercises.append(ex)
                    }
                    
                    realm.add(new)
                }
            }
            dismiss()
        } catch {
            print("Realm Save Error: \(error)")
        }
    }


}



private struct ExerciseRow: View {
    let ex: ExerciseEmbedded
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ex.name.isEmpty ? "Unbenannte Übung" : ex.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                HStack(spacing: 10) {
                    Label("\(ex.rounds)x", systemImage: "repeat")
                    Label("\(ex.workPhaseDuration)s Work", systemImage: "clock")
                    Label("\(ex.restPhaseDuration)s Rest", systemImage: "bed.double")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Text(totalText(ex))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
    private func totalText(_ e: ExerciseEmbedded) -> String {
        let sec = e.totalSeconds
        let m = sec / 60, s = sec % 60
        return String(format: "%d:%02d", m, s)
    }
    
}
