// LoveMapView.swift
// Everline
// Phase 3: MapKit integration with mood emoji annotations

import SwiftUI
import MapKit
import SwiftData

struct LoveMapView: View {
    @Query(sort: \Moment.date, order: .reverse) private var moments: [Moment]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )

    var pins: [AnnotationItem] {
        moments.compactMap { m in
            guard let lat = m.latitude, let lon = m.longitude else { return nil }
            return AnnotationItem(id: m.id, coordinate: .init(latitude: lat, longitude: lon), emoji: emoji(for: m.mood), title: m.title)
        }
    }
    
    private func emoji(for mood: String) -> String {
        // Basic mapping from stored mood string to an emoji
        let lower = mood.lowercased()
        if lower.contains("love") || lower.contains("happy") || lower.contains("joy") { return "🙂" }
        if lower.contains("fight") || lower.contains("angry") { return "😠" }
        if lower.contains("sad") || lower.contains("down") { return "😢" }
        return "🙂"
    }

    var body: some View {
        Map(position: .constant(.region(region))) {
            ForEach(pins) { item in
                Annotation(item.title, coordinate: item.coordinate) {
                    Text(item.emoji)
                        .font(.title)
                        .padding(6)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(radius: 2)
                }
            }
        }
        .onAppear {
            if let first = pins.first {
                region.center = first.coordinate
                region.span = .init(latitudeDelta: 5, longitudeDelta: 5)
            }
        }
        .navigationTitle("Love Map")
    }
}

struct AnnotationItem: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let emoji: String
    let title: String
}

#Preview {
    LoveMapView()
}
