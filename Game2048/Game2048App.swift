#if os(iOS)
import SwiftUI

@main
struct Game2048App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
#endif
