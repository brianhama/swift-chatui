import ChatUI
import SwiftUI

@main
struct ChatUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoRootScreen()
                .chatTheme(.messages)
        }
    }
}
