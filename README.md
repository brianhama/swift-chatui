# ChatUI

`ChatUI` is a reusable Swift Package for building Messages-inspired chat interfaces on iOS with SwiftUI. It provides a conversation list, pinned strip, transcript, composer, grouping logic, status rendering, typing indicators, reactions, theme defaults, and environment-driven customization hooks.

## Features

- Messages-like conversation list rows with unread, mute, pin, and swipe actions
- Reusable transcript and thread screens built on package-owned value models
- Multiline composer with growing text input and native-feeling send affordance
- Pure layout engine for grouping, separators, avatar rules, sender labels, and status visibility
- Theme presets with semantic colors, typography, metrics, animations, and formatters
- Renderer hooks for avatars, content, overlays, accessories, headers, and typing UI
- Demo app with direct chat, group chat, long transcript, optimistic sending, retry, and typing scenarios
- Unit tests for layout, status, titles, separators, fixtures, and reaction aggregation

## Installation

Add the package as a dependency in Xcode or with Swift Package Manager.

```swift
dependencies: [
    .package(path: "../ChatUI")
]
```

Then add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ChatUI", package: "ChatUI")
    ]
)
```

## Quick Start

```swift
import ChatUI
import SwiftUI

struct ThreadHost: View {
    let conversation: ChatConversation
    let messages: [ChatMessage]
    @State private var draft = ""

    var body: some View {
        ChatThreadScreen(
            conversation: conversation,
            messages: messages,
            draftText: $draft,
            onSendText: send
        )
        .chatTheme(.messages)
    }

    private func send(_ text: String) {
        // Insert your optimistic send and transport logic here.
    }
}
```

## Conversation List Example

```swift
NavigationStack {
    ConversationListScreen(
        conversations: previews,
        onOpenConversation: openConversation,
        onDeleteConversation: deleteConversation,
        onToggleMute: toggleMute,
        onToggleRead: toggleRead
    )
    .chatTheme(.messages)
    .navigationTitle("Messages")
}
```

The host owns filtering, searching, deletion, mute state, unread state, and navigation. `ConversationListScreen` only renders the data and forwards actions.

## Thread / Composer Example

```swift
ChatThreadScreen(
    conversation: conversation,
    messages: messages,
    draftText: $draft,
    typingParticipants: typingParticipants,
    configuration: .messages,
    onSendText: send,
    onRetryMessage: retry,
    onLoadEarlierMessages: loadEarlierMessages
)
.chatTheme(.messages)
```

`ChatThreadScreen` composes `ChatTranscriptView` and `MessageComposerView`. If you want finer control, you can use those two views independently.

## Theming and Customization

`ChatTheme.messages` is the default preset. A theme contains:

- `ChatColors`
- `ChatTypography`
- `ChatMetrics`
- `ChatTheme.Animations`
- `ChatFormatters`

Apply a custom theme with:

```swift
someView.chatTheme(customTheme)
```

Formatters let you customize conversation titles, row timestamps, date separators, status strings, and typing accessibility text without changing package internals.

## Renderer Hooks

The package uses environment-driven renderers instead of large generic view trees.

- `ChatAvatarRenderer`
- `ChatGroupAvatarRenderer`
- `MessageContentRenderer`
- `MessageOverlayRenderer`
- `MessageAccessoryRenderer`
- `ConversationRowAccessoryRenderer`
- `ChatHeaderRenderer`
- `TypingIndicatorRenderer`

Example:

```swift
ConversationListScreen(
    conversations: previews,
    onOpenConversation: openConversation
)
.chatAvatarRenderer(
    ChatAvatarRenderer { participant, size in
        AvatarView(participant: participant, size: size)
            .overlay(alignment: .bottomTrailing) {
                Circle().fill(.green).frame(width: 10, height: 10)
            }
    }
)
```

## Demo App Overview

The demo app lives in [`Demo/ChatUIDemo`](/Users/brianhamachek/swift-chatui/Demo/ChatUIDemo). It consumes the local package and includes:

- conversation list root
- direct and group chat threads
- pinned conversations
- typing indicator
- optimistic send lifecycle from `.sending` to `.read`
- failed outgoing message with retry
- long transcript with earlier-message loading
- long names, long text, and emoji-only messages

Generate the demo project with:

```bash
cd Demo/ChatUIDemo
xcodegen generate
```

## Testing

Run the package tests with Xcode:

```bash
xcodebuild test \
  -scheme ChatUI \
  -destination 'platform=iOS Simulator,id=<simulator-id>'
```

The included suite covers:

- transcript grouping
- date separator rules
- status visibility
- fallback title generation
- reaction aggregation
- deterministic fixture sanity

## Extensibility Notes

`ChatUI` is presentation-only by design.

- Host apps own networking, persistence, retries, syncing, and message lifecycle transitions.
- `MessageContent` already includes scaffolding for image, video, audio, and custom payloads.
- `MessageReaction` and `MessageOverlayRenderer` provide a path to richer Tapback-style UI later.
- `ChatThreadConfiguration` exposes thread-level behavior such as grouping threshold, jump-to-latest behavior, and host context menu actions.
- Domain models stay package-owned, so host apps can map their backend or persistence models at the UI boundary instead of conforming them to protocol hierarchies.
