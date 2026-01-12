import SwiftUI

/// Schedule tab - set auto-lock schedules
struct ScheduleView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)

                Text("Coming Soon")
                    .font(.title2.bold())

                Text("Schedule automatic lock times\nfor different parts of your day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("Schedule")
        }
    }
}

// MARK: - Previews

#Preview {
    ScheduleView()
}
