//
//  TrainingListView.swift
//  BoxTime
//
//  Created by Darian Hanci on 07.11.25.
//
import SwiftUI
import RealmSwift

struct TrainingListView: View {
    @ObservedResults(TrainingSessionObject.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false))
    var sessions
    
    // Timer- und HomeViewModel als Dependency Injection
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    
    @State private var showingNewEditor = false
    @State private var editingSession: TrainingSessionObject?   // <- NEU
    
    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    if sessions.isEmpty {
                        ContentUnavailableView(
                            "Noch keine Trainings",
                            systemImage: "list.bullet.rectangle.portrait",
                            description: Text("Erstelle dein erstes Training über den + Button.")
                        )
                    } else {
                        List {
                            ForEach(sessions) { session in
                                HStack {
                                    SessionRow(session: session)
                                    Spacer()
                                    
                                    Button {
                                        // Training direkt im Timer starten
                                        timerViewModel.load(session: session)
                                        homeViewModel.activeTab = .timer
                                    } label: {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.green)
                                            .padding(.horizontal, 6)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Training starten")
                                }
                                .contentShape(Rectangle())                // <- NEU (macht ganze Row tappbar)
                                .onTapGesture {
                                    print("Tapped")
                                    editingSession = session
                                } // <- NEU (Sheet öffnen)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        delete(session: session)
                                    } label: {
                                        Label("Löschen", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                // Beispiel: größere Banner nur für Nicht-Premium-Nutzer
                AdBannerView(
                    adUnitID: "ca-app-pub-3940256099942544/2435281174", // Test-ID
                    bannerType: .largeBanner
                )
                .frame(height: BannerType.largeBanner.height)
                .padding(.bottom, 24)

            }
            .navigationTitle("Trainings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Neues Training")
                }
            }
            .sheet(isPresented: $showingNewEditor) {
                TrainingEditorView()
            }
            .sheet(item: $editingSession) { session in
                TrainingEditorView(session: session)
            }
        }
    }
    
    private func delete(session: TrainingSessionObject) {
        guard let realm = session.realm else { return }
        try? realm.write {
            realm.delete(session)
        }
    }
}

private struct SessionRow: View {
    let session: TrainingSessionObject
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "figure.boxing")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                HStack(spacing: 8) {
                    Label(session.exerciseCountText, systemImage: "list.bullet")
                    Label(session.totalTimeText, systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}
