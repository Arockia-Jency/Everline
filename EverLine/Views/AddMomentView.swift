import SwiftUI
import PhotosUI
import SwiftData
import MapKit
import CoreLocation

struct AddMomentView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    // State for the new entry
    @State private var title = ""
    @State private var notes = ""
    @State private var date = Date()
    @State private var selectedMood: Mood = .love
    
    // Photo Picker state
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedData: Data?
    
    // Location state
    @State private var location: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var showSuccessFeedback = false

    var body: some View {
        NavigationStack {
            Form {
                Section("The Memory") {
                    TextField("Title (e.g., Our First Date)", text: $title)
                    DatePicker("When?", selection: $date, displayedComponents: .date)
                    
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Label(mood.rawValue, systemImage: mood.icon).tag(mood)
                        }
                    }
                }
                
                Section("Photo") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedData, let uiImage = UIImage(data: selectedData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Label("Select a Photo", systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                
                Section("Location") {
                    ZStack(alignment: .center) {
                        Map(initialPosition: .region(region)) {
                            if let location {
                                Annotation("Moment", coordinate: location) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.title)
                                        .foregroundStyle(.pink)
                                }
                            }
                        }
                        .onMapCameraChange { context in
                            region = context.region
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        
                        // Center crosshair
                        if location == nil {
                            Image(systemName: "plus")
                                .foregroundStyle(.pink)
                                .font(.title)
                        }
                    }
                    
                    Button {
                        location = region.center
                    } label: {
                        Label(location == nil ? "Pin Current Center" : "Repin Location", systemImage: "mappin.circle.fill")
                    }
                    
                    if location != nil {
                        Button(role: .destructive) {
                            location = nil
                        } label: {
                            Text("Remove Location")
                        }
                    }
                }
                
                Section("Thoughts") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMoment()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedData = data
                    }
                }
            }
            .sensoryFeedback(.success, trigger: showSuccessFeedback)
        }
    }
    
    private func saveMoment() {
        let newMoment = Moment(
            title: title,
            notes: notes,
            date: date,
            mood: selectedMood.rawValue,
            photoData: selectedData,
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        modelContext.insert(newMoment)
        showSuccessFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}
