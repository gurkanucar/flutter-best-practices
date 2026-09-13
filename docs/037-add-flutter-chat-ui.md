# Chat Screens with flutter_chat_ui

Uses [`flutter_chat_ui`](https://pub.dev/packages/flutter_chat_ui) **2.x** +
[`flutter_chat_core`](https://pub.dev/packages/flutter_chat_core) — a backend-agnostic chat UI (message list,
composer, animations, scroll-to-bottom). Pure Flutter: every platform.

It's **UI only** — storage, sync and realtime (Firebase, Supabase, websockets…) are yours.

## material_ui
Since 2.12.0 the package imports `package:material_ui` itself (not `flutter/material`), so it fits this app without
wrappers, and `ChatTheme.fromThemeData` accepts our `ThemeData`.

## Steps

### 1. Add dependencies
```bash
flutter pub add flutter_chat_ui flutter_chat_core
```
Network images (avatars, image messages) need `INTERNET` in the main Android manifest and
`com.apple.security.network.client` in both macOS entitlements files.

### 2. Controller and models
```dart
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

final controller = InMemoryChatController(messages: initialMessages);   // dispose() it

controller.insertMessage(
  Message.text(
    id: Ids.uuidV7(),            // must be unique — duplicates throw in debug (041)
    authorId: 'me',
    text: 'Hello',
    createdAt: DateTime.now().toUtc(),
  ),
);
controller.updateMessage(oldMessage, newMessage);   // e.g. status, seenAt, edited text
controller.removeMessage(message);
controller.setMessages(messages);                   // replace all (e.g. after loading)
```
Message types: `Message.text`, `.image(source:)`, `.file(source:, name:)`, `.video`, `.audio`, `.system`, `.custom`.
Delivery state comes from `sentAt` / `deliveredAt` / `seenAt` / `failedAt` or `status:`.

Implement `ChatController` yourself to back it with a database or stream (e.g. Drift, [022](022-add-drift.md)).

### 3. The screen
```dart
Scaffold(
  appBar: AppBar(title: const Text('Chat')),
  body: Chat(                                     // needs bounded height (Scaffold body is fine)
    currentUserId: 'me',
    chatController: controller,
    resolveUser: (id) async => User(id: id, name: names[id], imageSource: avatars[id]),  // cached
    onMessageSend: (text) => controller.insertMessage(/* … */),                           // text is trimmed
    theme: ChatTheme.fromThemeData(Theme.of(context)),                                     // light + dark
    timeFormat: DateFormat.Hm(Localizations.localeOf(context).toString()),
    builders: Builders(/* see below */),
  ),
)
```

### 4. Builders you will need
```dart
Builders(
  // Built-in strings are English-only → localized composer and empty state:
  composerBuilder: (context) => Composer(
    hintText: l10n.chatHint,
    topWidget: isTyping ? const IsTypingIndicator() : null,   // typing state is yours
  ),
  emptyChatListBuilder: (context) => EmptyChatList(text: l10n.chatEmpty),

  // Only text has a default renderer. Without this, image messages assert
  // (or add the flyer_chat_image_message package):
  imageMessageBuilder: (context, message, index, {required isSentByMe, groupStatus}) =>
      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(message.source, width: 240)),

  // Wrap every message, e.g. to show the quoted message of a reply:
  chatMessageBuilder: (context, message, index, animation, child, {isRemoved, required isSentByMe, groupStatus}) =>
      ChatMessage(
        message: message,
        index: index,
        animation: animation,
        isRemoved: isRemoved,
        groupStatus: groupStatus,
        topWidget: replyQuoteFor(message),        // replyToMessageId is stored but not drawn
        child: child,
      ),
)
```
Attachments: pass `onAttachmentTap:` to show the attachment button, then pick with image_picker
([024](024-add-image-picker.md)) and insert a `Message.image`.

### 5. Demo — `lib/chat/chat_demo_page.dart`
**Home → Demos → Chat**: a fake bot with an image message, typing indicator, echo replies that quote your message
and a "seen" update on your message. Test: `test/qr_and_chat_test.dart`.

## v1 → v2
| v1 | v2 |
|---|---|
| `messages: List<types.Message>` | `chatController` |
| `user: types.User` | `currentUserId` + `resolveUser` |
| `onSendPressed(PartialText)` | `onMessageSend(String)` |
| `author: User`, `createdAt: int` ms | `authorId`, `createdAt: DateTime` |
| `DefaultChatTheme`, `ChatL10n` | `ChatTheme`, builders |

## Notes
- Pagination: `ChatAnimatedList(onEndReached: loadOlder)` inside `chatAnimatedListBuilder`.
- Store times in UTC; `timeFormat` formats them in local time.
- Widget tests: the typing indicator animates forever → use `pump(duration)`, not `pumpAndSettle()`.
