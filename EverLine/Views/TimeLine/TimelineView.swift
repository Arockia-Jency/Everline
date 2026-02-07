import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Moment.date, order: .reverse) private var moments: [Moment]
    @State private var searchText = ""
    @State private var selectedMoodFilter: String? = nil
    
    // Filtered list based on search and mood
    var filteredMoments: [Moment] {
        moments.filter { moment in
            let matchesSearch = searchText.isEmpty || moment.title.localizedCaseInsensitiveContains(searchText)
            let matchesMood = selectedMoodFilter == nil || moment.mood == selectedMoodFilter
            return matchesSearch && matchesMood
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Horizontal Mood Filter Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterButton(title: "All", isSelected: selectedMoodFilter == nil) {
                                selectedMoodFilter = nil
                            }
                            ForEach(Mood.allCases, id: \.self) { mood in
                                FilterButton(title: mood.rawValue, isSelected: selectedMoodFilter == mood.rawValue) {
                                    selectedMoodFilter = mood.rawValue
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 2. The Timeline List
                    if filteredMoments.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredMoments) { moment in
                                NavigationLink(destination: MomentDetailView(moment: moment)) {
                                    MomentRow(moment: moment) {
                                        deleteMoment(moment)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 100) // Space for floating tab bar
            }
            .safeAreaInset(edge: .bottom){
                Color.clear.frame(height:90)
            }
            .navigationTitle("Our Story")
            .searchable(
                text: $searchText,
                placement:.navigationBarDrawer(displayMode: .always),
                prompt: "Search memories...")
        }
    }
    
    private func deleteMoment(_ moment: Moment) {
        modelContext.delete(moment)
        try? modelContext.save()
    }
}

// Subview for the filter capsules
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pink : Color.pink.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .pink)
                .clipShape(Capsule())
        }
    }
}
