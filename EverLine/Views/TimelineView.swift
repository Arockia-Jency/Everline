import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Moment.date, order: .reverse) private var moments: [Moment]
    @State private var searchText = ""
    @State private var selectedMoodFilter: String? = nil
    @State private var selectedDateRange: DateRangeFilter = .all
    @State private var showFavoritesOnly = false
    
    // Security Manager for photo decryption
    var securityManager: SecurityManager
    
    // Date range filter options
    enum DateRangeFilter: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        
        func matches(date: Date) -> Bool {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .all:
                return true
            case .today:
                return calendar.isDateInToday(date)
            case .week:
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    // Filtered list based on search, mood, and date range
    var filteredMoments: [Moment] {
        moments.filter { moment in
            let matchesSearch = searchText.isEmpty || 
                moment.title.localizedCaseInsensitiveContains(searchText) ||
                moment.notes.localizedCaseInsensitiveContains(searchText)
            
            let matchesMood: Bool
            if let selectedMood = selectedMoodFilter {
                // Support both exact match and partial match (case-insensitive)
                matchesMood = moment.mood.localizedCaseInsensitiveContains(selectedMood) ||
                              selectedMood.localizedCaseInsensitiveContains(moment.mood)
            } else {
                matchesMood = true
            }
            
            let matchesDateRange = selectedDateRange.matches(date: moment.date)
            
            let matchesFavorite = showFavoritesOnly ? moment.isFavorite : true
            
            return matchesSearch && matchesMood && matchesDateRange && matchesFavorite
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Horizontal Mood Filter Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterButton(
                                title: "All",
                                count: moments.count,
                                isSelected: selectedMoodFilter == nil
                            ) {
                                selectedMoodFilter = nil
                            }
                            ForEach(Mood.allCases, id: \.self) { mood in
                                let count = moments.filter { $0.mood.localizedCaseInsensitiveContains(mood.rawValue) }.count
                                FilterButton(
                                    title: mood.rawValue,
                                    count: count,
                                    isSelected: selectedMoodFilter == mood.rawValue
                                ) {
                                    selectedMoodFilter = mood.rawValue
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 2. Date Range Filter (New!)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(DateRangeFilter.allCases, id: \.self) { range in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedDateRange = range
                                    }
                                } label: {
                                    Text(range.rawValue)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedDateRange == range ? Color.blue : Color.blue.opacity(0.1))
                                        .foregroundStyle(selectedDateRange == range ? .white : .blue)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. The Timeline List
                    if filteredMoments.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredMoments) { moment in
                                NavigationLink(destination: MomentDetailView(moment: moment, securityManager: securityManager)) {
                                    MomentRow(moment: moment, securityManager: securityManager) {
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            showFavoritesOnly.toggle()
                        }
                    } label: {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundStyle(showFavoritesOnly ? .pink : .primary)
                    }
                }
            }
        }
    }
    
    private func deleteMoment(_ moment: Moment) {
        modelContext.delete(moment)
        try? modelContext.save()
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            if moments.isEmpty {
                // No moments at all
                ContentUnavailableView(
                    "No Moments Yet",
                    systemImage: "heart.text.square",
                    description: Text("Tap the + button to create your first memory together")
                )
            } else if !searchText.isEmpty && selectedMoodFilter != nil {
                // Both search and filter active
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("No moments found matching '\(searchText)' with mood '\(selectedMoodFilter!)'")
                )
            } else if !searchText.isEmpty {
                // Only search active
                ContentUnavailableView.search(text: searchText)
            } else if selectedMoodFilter != nil {
                // Only filter active
                VStack(spacing: 16) {
                    Image(systemName: moodIcon(for: selectedMoodFilter!))
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("No \(selectedMoodFilter!) Moments")
                        .font(.title2.bold())
                    
                    Text("You haven't created any moments with this mood yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        selectedMoodFilter = nil
                    } label: {
                        Text("Clear Filter")
                            .font(.subheadline.bold())
                    }
                    .buttonStyle(.bordered)
                    .tint(.pink)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private func moodIcon(for mood: String) -> String {
        if let matchingMood = Mood.allCases.first(where: { mood.contains($0.rawValue) }) {
            return matchingMood.icon
        }
        return "heart.fill"
    }
}

// Subview for the filter capsules
struct FilterButton: View {
    let title: String
    var count: Int = 0
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
            
            if count > 0 {
                Text("(\(count))")
                    .font(.caption.bold())
                    .opacity(0.8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.pink : Color.pink.opacity(0.1))
        .foregroundStyle(isSelected ? .white : .pink)
        .clipShape(Capsule())
        // Make the entire area of the capsule sensitive to taps
        .contentShape(Rectangle())
        .onTapGesture {
            // Log for debugging
            print("Filter tapped: \(title)")
            if count > 0 || title == "All" {
                action()
            }
        }
        .opacity(count == 0 && title != "All" ? 0.5 : 1.0)
    }
}
