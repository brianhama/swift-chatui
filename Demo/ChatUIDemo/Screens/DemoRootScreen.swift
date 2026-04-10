import ChatUI
import SwiftUI

struct DemoRootScreen: View {
    @State private var store = DemoStore()

    var body: some View {
        NavigationSplitView {
            ConversationListScreen(
                conversations: store.filteredPreviews,
                selection: Binding(
                    get: { store.selectedConversationID },
                    set: { store.selectedConversationID = $0 }
                ),
                onOpenConversation: store.openConversation,
                onDeleteConversation: store.deleteConversation,
                onToggleMute: store.toggleMute,
                onToggleRead: store.toggleRead
            )
            .navigationTitle("Messages")
            .searchable(text: $store.searchText, prompt: "Search")
        } detail: {
            if let conversation = store.activeConversation {
                ChatThreadScreen(
                    conversation: conversation,
                    messages: store.activeMessages,
                    draftText: store.draftBinding(),
                    typingParticipants: store.activeTypingParticipants,
                    onSendText: store.send,
                    onRetryMessage: store.retry,
                    onLoadEarlierMessages: store.loadEarlierMessages
                )
            } else {
                ContentUnavailableView("Select a Conversation", systemImage: "message")
            }
        }
    }
}
