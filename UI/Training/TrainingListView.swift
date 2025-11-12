import SwiftUI
import RealmSwift

struct TrainingListView: View {
    @ObservedResults(TrainingSessionObject.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false))
    var sessions
    
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    
    @State private var showingNewEditor = false
    @State private var editingSession: TrainingSessionObject?
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var rowBackgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.systemGray5)   // minimal heller
        } else {
            return Color(UIColor.secondarySystemBackground)
        }
    }

    private var listBackgroundColor: Color {
        if colorScheme == .dark {
            return Color(UIColor.systemGray6)   // nur ein Tick dunkler
        } else {
            return Color(UIColor.systemGroupedBackground)
        }
    }

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
                                HStack(spacing: 10) {
                                    SessionRow(session: session)
                                    
                                    Spacer(minLength: 12)
                                    
                                    Button {
                                        timerViewModel.load(session: session)
                                        homeViewModel.activeTab = .timer
                                        timerViewModel.activeTrainingSession = session
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(10)
                                            .background(
                                                Circle()
                                                    .fill(Color.green.opacity(0.2))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundStyle(.green)
                                    .accessibilityLabel("Training starten")
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 8) // <= weniger horizontaler Rand
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(rowBackgroundColor)
                                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingSession = session
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)) // <= dichter am Bildschirmrand
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        delete(session: session)
                                    } label: {
                                        Label("Löschen", systemImage: "trash")
                                    }
                                }
                            }
                            
                        }
                        .listStyle(.automatic)
                        .scrollContentBackground(.hidden) // damit der Hintergrund durchscheint
                     //   .background(listBackgroundColor)
                     
                    }
                }
                
                if !PremiumManager.shared.hasPremium {
                    AdBannerView(
                        adUnitID: "ca-app-pub-3940256099942544/2435281174",
                        bannerType: .largeBanner
                    )
                    .frame(height: BannerType.largeBanner.height)
                    .padding(.bottom, 16)
                }
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
        guard let thawed = session.thaw(), let realm = thawed.realm else { return }
        try? realm.write {
            realm.delete(thawed)
        }
    }
}

private struct SessionRow: View {
    @ObservedRealmObject var session: TrainingSessionObject
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon-Box
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "figure.boxing")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            
            // Texte
            VStack(alignment: .leading, spacing: 6) {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 16) {
                    Label(session.exerciseCountText, systemImage: "list.bullet")
                    Label(session.totalTimeText, systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .labelStyle(TightLabelStyle())
            }
        }
    }
}

struct TightLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {          // hier stellst du den Abstand ein
            configuration.icon
            configuration.title
        }
    }
}

