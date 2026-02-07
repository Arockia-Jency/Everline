//
//  StatsView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI
import SwiftData
import Charts
import MapKit
import Combine

// MARK: - View Model
@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var moodCounts: [String: Int] = [:]
    @Published private(set) var totalMoments: Int = 0
    @Published private(set) var daysTogether: Int = 0
    @Published private(set) var topMood: String = ""
    @Published private(set) var totalPhotos: Int = 0
    @Published private(set) var totalWords: Int = 0
    @Published private(set) var uniqueLocations: Int = 0
    @Published private(set) var happyStreak: Int = 0
    @Published private(set) var currentWeekMood: String = ""
    @Published private(set) var weekdayActivity: [String: Int] = [:]
    @Published private(set) var furthestDistance: Double = 0
    @Published private(set) var moodOfWeek: String = ""
    
    func compute(from moments: [Moment]) {
        // 1. Total moments
        self.totalMoments = moments.count
        
        // 2. Days together (from first moment to now)
        if let firstMoment = moments.sorted(by: { $0.date < $1.date }).first {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: firstMoment.date, to: Date())
            self.daysTogether = components.day ?? 0
        }
        
        // 3. Mood counts and top mood
        var counts: [String: Int] = [:]
        for moment in moments {
            counts[moment.mood, default: 0] += 1
        }
        self.moodCounts = counts
        self.topMood = counts.max(by: { $0.value < $1.value })?.key ?? "Love"
        
        // 4. Total photos
        self.totalPhotos = moments.filter { $0.encryptedPhotoData != nil }.count
        
        // 5. Total words in notes
        self.totalWords = moments.reduce(0) { $0 + $1.notes.split(separator: " ").count }
        
        // 6. Unique locations
        let locationCoordinates = moments.compactMap { moment -> String? in
            guard let lat = moment.latitude, let lon = moment.longitude else { return nil }
            return "\(lat),\(lon)"
        }
        self.uniqueLocations = Set(locationCoordinates).count
        
        // 7. Happy Streak
        self.happyStreak = calculateHappyStreak(moments: moments)
        
        // 8. Weekday activity
        var weekdayCounts: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        for moment in moments {
            let weekday = dateFormatter.string(from: moment.date)
            weekdayCounts[weekday, default: 0] += 1
        }
        self.weekdayActivity = weekdayCounts
        
        // 9. Furthest distance
        self.furthestDistance = calculateFurthestDistance(moments: moments)
        
        // 10. Mood of the week (last 7 days)
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentMoments = moments.filter { $0.date >= weekAgo }
        var recentMoodCounts: [String: Int] = [:]
        for moment in recentMoments {
            recentMoodCounts[moment.mood, default: 0] += 1
        }
        self.moodOfWeek = recentMoodCounts.max(by: { $0.value < $1.value })?.key ?? "Love"
    }
    
    private func calculateHappyStreak(moments: [Moment]) -> Int {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: moments) { calendar.startOfDay(for: $0.date) }
        let days = byDay.keys.sorted()
        
        var best = 0
        var current = 0
        var lastDay: Date?
        
        for day in days {
            let entries = byDay[day] ?? []
            let hasFight = entries.contains(where: { $0.mood.contains("Argument") || $0.mood.contains("Fight") })
            
            if let last = lastDay, let diff = calendar.dateComponents([.day], from: last, to: day).day, diff > 1 {
                current = 0
            }
            
            if hasFight {
                current = 0
            } else {
                current += 1
                best = max(best, current)
            }
            lastDay = day
        }
        return best
    }
    
    private func calculateFurthestDistance(moments: [Moment]) -> Double {
        let locations = moments.compactMap { moment -> CLLocationCoordinate2D? in
            guard let lat = moment.latitude, let lon = moment.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        guard locations.count >= 2 else { return 0 }
        
        var maxDistance: Double = 0
        for i in 0..<locations.count {
            for j in (i+1)..<locations.count {
                let loc1 = CLLocation(latitude: locations[i].latitude, longitude: locations[i].longitude)
                let loc2 = CLLocation(latitude: locations[j].latitude, longitude: locations[j].longitude)
                let distance = loc1.distance(from: loc2) / 1000 // Convert to km
                maxDistance = max(maxDistance, distance)
            }
        }
        return maxDistance
    }
}

// MARK: - Main Stats View
struct StatsView: View {
    @Query(sort: \Moment.date, order: .reverse) private var moments: [Moment]
    @StateObject private var vm = StatsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Hero Stats
                    heroStatsSection
                    
                    // Mood Distribution Chart
                    moodChartSection
                    
                    // Story Milestones
                    storyMilestonesSection
                    
                    // Geographical Footprint
                    geographicalSection
                    
                    // Media & Expression Stats
                    mediaStatsSection
                    
                    // Relationship Streaks
                    streakSection
                    
                    // Weekly Activity Heatmap
                    weekdayActivitySection
                }
                .padding()
                .padding(.bottom, 100) // Space for floating tab bar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Relationship Dashboard")
            .onAppear {
                vm.compute(from: moments)
            }
            .onChange(of: moments) { _, newMoments in
                vm.compute(from: newMoments)
            }
        }
    }
    
    // MARK: - Hero Stats Section
    @ViewBuilder
    private var heroStatsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Days Together",
                    value: "\(vm.daysTogether)",
                    icon: "heart.fill",
                    color: .pink
                )
                
                StatCard(
                    title: "Moments",
                    value: "\(vm.totalMoments)",
                    icon: "sparkles",
                    color: .purple
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Photos",
                    value: "\(vm.totalPhotos)",
                    icon: "camera.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Locations",
                    value: "\(vm.uniqueLocations)",
                    icon: "map.fill",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Mood Chart Section
    @ViewBuilder
    private var moodChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Mood Distribution", subtitle: "Your emotional journey")
            
            if !vm.moodCounts.isEmpty {
                VStack(spacing: 16) {
                    Chart {
                        ForEach(vm.moodCounts.sorted(by: { $0.value > $1.value }), id: \.key) { mood, count in
                            SectorMark(
                                angle: .value("Count", count),
                                innerRadius: .ratio(0.6),
                                outerRadius: .ratio(1.0)
                            )
                            .foregroundStyle(by: .value("Mood", mood))
                            .cornerRadius(5)
                        }
                    }
                    .frame(height: 220)
                    .chartLegend(position: .bottom, spacing: 16)
                    
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        Text("Top Mood: **\(vm.topMood)**")
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }
            } else {
                ContentUnavailableView(
                    "No Mood Data",
                    systemImage: "chart.pie",
                    description: Text("Start adding moments to see your mood distribution")
                )
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Story Milestones Section
    @ViewBuilder
    private var storyMilestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Story Milestones", subtitle: "Your journey in numbers")
            
            VStack(spacing: 12) {
                MilestoneRow(
                    icon: "book.fill",
                    title: "Total Memories",
                    value: "\(vm.totalMoments)",
                    color: .purple
                )
                
                MilestoneRow(
                    icon: "calendar.circle.fill",
                    title: "Days Together",
                    value: "\(vm.daysTogether)",
                    color: .pink
                )
                
                if !vm.weekdayActivity.isEmpty {
                    let topDay = vm.weekdayActivity.max(by: { $0.value < $1.value })
                    MilestoneRow(
                        icon: "star.fill",
                        title: "Most Active Day",
                        value: topDay?.key ?? "N/A",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Geographical Section
    @ViewBuilder
    private var geographicalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Geographical Footprint", subtitle: "Places you've been together")
            
            VStack(spacing: 12) {
                GeoStatRow(
                    icon: "mappin.circle.fill",
                    title: "Unique Locations",
                    value: "\(vm.uniqueLocations)",
                    color: .green
                )
                
                if vm.furthestDistance > 0 {
                    GeoStatRow(
                        icon: "airplane.circle.fill",
                        title: "Furthest Distance",
                        value: String(format: "%.1f km", vm.furthestDistance),
                        color: .blue
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Media Stats Section
    @ViewBuilder
    private var mediaStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Media & Expression", subtitle: "Your story in words and images")
            
            HStack(spacing: 16) {
                MediaStatCard(
                    icon: "photo.fill",
                    title: "Photos",
                    value: "\(vm.totalPhotos)",
                    color: .blue
                )
                
                MediaStatCard(
                    icon: "text.quote",
                    title: "Words",
                    value: "\(vm.totalWords)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Streak Section
    @ViewBuilder
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Relationship Streaks", subtitle: "Consistency & highlights")
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.title)
                            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Happy Streak")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("\(vm.happyStreak) Days")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(.blue)
                        Text("Mood of the Week: **\(vm.moodOfWeek)**")
                            .font(.subheadline)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Weekday Activity Section
    @ViewBuilder
    private var weekdayActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Activity Heatmap", subtitle: "When you create memories")
            
            if !vm.weekdayActivity.isEmpty {
                let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                Chart {
                    ForEach(weekdays, id: \.self) { day in
                        let count = vm.weekdayActivity[day] ?? 0
                        BarMark(
                            x: .value("Day", day),
                            y: .value("Count", count)
                        )
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(8)
                    }
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                ContentUnavailableView(
                    "No Activity Data",
                    systemImage: "calendar",
                    description: Text("Start adding moments to see your activity pattern")
                )
                .frame(height: 180)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(color.gradient)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct MilestoneRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.bold())
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct GeoStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.bold())
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct MediaStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color.gradient)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: Moment.self, inMemory: true)
}

