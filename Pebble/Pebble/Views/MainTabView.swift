import SwiftUI

/// Main tab bar navigation
struct MainTabView: View {

    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var modeManager: ModeManager

    @State private var selectedTab: Tab = .pebble

    enum Tab {
        case pebble
        case schedule
        case activity
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Pebble (Home) Tab
            HomeView(viewModel: dashboardViewModel, modeManager: modeManager)
                .tabItem {
                    Label("Pebble", systemImage: "circle.fill")
                }
                .tag(Tab.pebble)

            // Schedule Tab
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(Tab.schedule)

            // Activity Tab
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "chart.bar.fill")
                }
                .tag(Tab.activity)

            // Settings Tab
            SettingsTabView(viewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(.primary)
    }
}

// MARK: - Previews

#Preview {
    MainTabView(
        dashboardViewModel: .preview,
        settingsViewModel: .preview,
        modeManager: .preview
    )
}
