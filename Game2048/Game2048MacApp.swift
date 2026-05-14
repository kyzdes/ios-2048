#if os(macOS)
import SwiftUI

@main
struct Game2048MacApp: App {
    @AppStorage(GamePreferenceKey.prefersDarkTheme)
    private var prefersDarkTheme = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 700)
                .preferredColorScheme(prefersDarkTheme ? .dark : .light)
        }
        .defaultSize(width: 560, height: 780)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .preferredColorScheme(prefersDarkTheme ? .dark : .light)
        }
    }
}
#endif
