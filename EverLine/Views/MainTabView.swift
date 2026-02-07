import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .timeline
    @State private var isShowingAdd = false
    @State private var isShowingSettings = false

    enum Tab: String, CaseIterable {
        case timeline = "Timeline"
        case map = "Love Map"
        case stats = "Stats"
        
        var icon: String {
            switch self {
            case .timeline: return "clock.fill"
            case .map: return "map.fill"
            case .stats: return "chart.pie.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .timeline:
                    TimelineView()
                case .map:
                    NavigationStack { LoveMapView() }
                case .stats:
                    StatsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Floating Tab Bar
            HStack(spacing: 0) {
                tabButton(for: .timeline)
                tabButton(for: .map)
                
                // Central Add Button
                Button {
                    isShowingAdd = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(.pink.gradient)
                            .frame(width: 54, height: 54)
                            .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                }
                .offset(y: -25)
                .padding(.horizontal, 10)
                
                tabButton(for: .stats)
                
                Button {
                    isShowingSettings = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $isShowingAdd) {
            AddMomentView()
        }
        .sheet(isPresented: $isShowingSettings){
            SettingsView()
        }
    }
    @ViewBuilder
    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(selectedTab == tab ? .pink : .secondary)
                
                if selectedTab == tab {
                    Text(tab.rawValue)
                        .font(.caption2.bold())
                        .foregroundStyle(.pink)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Moment.self, inMemory: true)
}
