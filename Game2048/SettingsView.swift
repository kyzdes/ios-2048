#if os(macOS)
import SwiftUI

struct SettingsView: View {
    @AppStorage(GamePreferenceKey.invertHorizontalTrackpadSwipes)
    private var invertHorizontalTrackpadSwipes = false
    @AppStorage(GamePreferenceKey.disableTileAnimations)
    private var disableTileAnimations = false
    @AppStorage(GamePreferenceKey.prefersDarkTheme)
    private var prefersDarkTheme = false

    var body: some View {
        Form {
            Section("Controls") {
                Toggle("Invert horizontal trackpad swipes", isOn: $invertHorizontalTrackpadSwipes)

                Text("Vertical swipe behavior stays unchanged.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Section("Appearance") {
                Toggle("Disable tile animations", isOn: $disableTileAnimations)
                Toggle("Dark theme", isOn: $prefersDarkTheme)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 420, height: 230)
    }
}
#endif
