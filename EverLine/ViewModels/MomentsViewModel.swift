import SwiftUI
import SwiftData
import Combine

@MainActor
final class MomentsViewModel: ObservableObject {
    @Published var moments: [Moment] = []
    @Published var searchText: String = "" {
        didSet { loadMoments() }
    }
    @Published var selectedMood: String? = nil {
        didSet { loadMoments() }
    }
    
    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        loadMoments()
    }
    
    func replaceContext(_ newContext: ModelContext) {
        self.context = newContext
    }

    func loadMoments() {
        var predicate: Predicate<Moment>? = nil
        
        if !searchText.isEmpty && selectedMood != nil {
            let mood = selectedMood!
            predicate = #Predicate<Moment> { moment in
                (moment.title.localizedStandardContains(searchText) || moment.notes.localizedStandardContains(searchText)) && moment.mood == mood
            }
        } else if !searchText.isEmpty {
            predicate = #Predicate<Moment> { moment in
                moment.title.localizedStandardContains(searchText) || moment.notes.localizedStandardContains(searchText)
            }
        } else if let mood = selectedMood {
            predicate = #Predicate<Moment> { moment in
                moment.mood == mood
            }
        }

        let request = FetchDescriptor<Moment>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Moment.date, order: .reverse)]
        )
        
        do {
            moments = try context.fetch(request)
        } catch {
            print("Failed to fetch moments: \(error)")
        }
    }
    
    func refresh() {
        loadMoments()
    }
}

