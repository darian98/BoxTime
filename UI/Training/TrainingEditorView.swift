//
//  TrainingEditorView.swift
//  BoxTime
//
//  Created by Darian Hanci on 07.11.25.
//
// TrainingEditorView.swift
import SwiftUI
import RealmSwift

struct TrainingEditorView: View {
    // Wenn nil ⇒ Neuerstellung, sonst Bearbeitung
    @ObservedRealmObject var session: TrainingSessionObject
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingExerciseSheet = false
    @State private var editingIndex: Int? = nil
    
    // Init für "Neu"
    init() {
        let new = TrainingSessionObject()
        _session = ObservedRealmObject(wrappedValue: new)
    }
    
    // Init für "Bearbeiten"
    init(session: TrainingSessionObject) {
        _session = ObservedRealmObject(wrappedValue: session)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Allgemein") {
                    TextField("Titel", text: $session.title)
                        .textInputAutocapitalization(.words)
                    DatePicker("Datum", selection: $session.date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    if session.exercises.isEmpty {
                        ContentUnavailableView(
                            "Noch keine Übungen",
                            systemImage: "dumbbell",
                            description: Text("Füge unten eine Übung hinzu.")
                        )
                    } else {
                        // EmbeddedObject ist nicht Identifiable ⇒ Indizes verwenden
                        ForEach(Array(session.exercises.enumerated()), id: \.offset) { index, ex in
                            Button {
                                editingIndex = index
                                showingExerciseSheet = true
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
                        editingIndex = nil
                        showingExerciseSheet = true
                    } label: {
                        Label("Übung hinzufügen", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Übungen")
                } footer: {
                    HStack {
                        Label("Gesamtzeit: \(session.totalTimeText)", systemImage: "clock")
                        Spacer()
                        Label("\(session.exercises.count) Üb.", systemImage: "list.bullet")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(session.realm == nil ? "Training erstellen" : "Training bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { handleCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { handleSave() }
                        .disabled(session.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingExerciseSheet) {
                ExerciseEditorSheet(
                    initial: currentEditingExercise(),
                    onSave: { updated in
                        applyExercise(updated)
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func handleCancel() {
        if let realm = session.realm {
            // Bearbeitungsfall ⇒ Änderungen sind live, deshalb nichts tun
            realm.refresh() // optional
        }
        dismiss()
    }
    
    private func handleSave() {
        if let realm = session.realm {
            // Bereits in Realm ⇒ Felder sind gebunden, also einfach schließen
            dismiss()
            return
        }
        // Neu ⇒ hinzufügen
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(session)
            }
            dismiss()
        } catch {
            // einfache Fehlerbehandlung
            print("Realm Save Error: \(error)")
        }
    }
    
    private func removeExercise(at index: Int) {
        guard let realm = session.realm else {
            session.exercises.remove(at: index)
            return
        }
        try? realm.write {
            session.exercises.remove(at: index)
        }
    }
    
    private func currentEditingExercise() -> ExerciseEmbedded? {
        guard let idx = editingIndex, session.exercises.indices.contains(idx) else { return nil }
        return session.exercises[idx]
    }
    
    private func applyExercise(_ newValue: ExerciseEmbedded) {
        if let idx = editingIndex, session.exercises.indices.contains(idx) {
            // Update bestehender Eintrag
            if let realm = session.realm {
                try? realm.write {
                    session.exercises[idx].name = newValue.name
                    session.exercises[idx].rounds = newValue.rounds
                    session.exercises[idx].workPhaseDuration = newValue.workPhaseDuration
                    session.exercises[idx].restPhaseDuration = newValue.restPhaseDuration
                }
            } else {
                session.exercises[idx] = newValue
            }
        } else {
            // Neuer Eintrag
            if let realm = session.realm {
                try? realm.write {
                    session.exercises.append(newValue)
                }
            } else {
                session.exercises.append(newValue)
            }
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

