import 'dart:async';

import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../ids/ids.dart';
import '../l10n/l10n_extension.dart';

/// flutter_chat_ui v2 — already built on material_ui, so no compatibility wrappers.
class ChatDemoPage extends StatefulWidget {
  const ChatDemoPage({super.key});

  @override
  State<ChatDemoPage> createState() => _ChatDemoPageState();
}

class _ChatDemoPageState extends State<ChatDemoPage> {
  static const _me = 'me';
  static const _bot = 'bot';

  InMemoryChatController? _controller;
  Timer? _replyTimer;
  bool _botTyping = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final l10n = context.l10n;
    final now = DateTime.now().toUtc();
    // A real app loads these from its backend/database and listens for new ones.
    _controller = InMemoryChatController(
      messages: [
        Message.text(
          id: Ids.uuidV7(),
          authorId: _bot,
          text: l10n.chatWelcome,
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
        Message.image(
          id: Ids.uuidV7(),
          authorId: _bot,
          source: 'https://picsum.photos/id/1015/600/400',
          width: 600,
          height: 400,
          createdAt: now.subtract(const Duration(minutes: 1)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _send(String text) {
    final controller = _controller!;
    final now = DateTime.now().toUtc();
    // Message ids must be unique (duplicates throw in debug) — UUID v7 also sorts by time.
    final message = TextMessage(id: Ids.uuidV7(), authorId: _me, text: text, createdAt: now, sentAt: now);
    controller.insertMessage(message);

    // Fake the other side. A real app receives replies from a websocket/stream.
    _replyTimer?.cancel();
    setState(() => _botTyping = true);
    _replyTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final replyTime = DateTime.now().toUtc();
      controller.updateMessage(message, message.copyWith(seenAt: replyTime));
      controller.insertMessage(
        TextMessage(
          id: Ids.uuidV7(),
          authorId: _bot,
          text: context.l10n.chatEcho(text),
          replyToMessageId: message.id,
          createdAt: replyTime,
        ),
      );
      setState(() => _botTyping = false);
    });
  }

  Future<User?> _resolveUser(String id) async => switch (id) {
        _me => const User(id: _me, name: 'Me'),
        _bot => const User(id: _bot, name: 'Bot'),
        _ => null,
      };

  /// v2 stores `replyToMessageId` but draws no quote — build it yourself.
  Widget? _replyQuote(Message message) {
    if (message case TextMessage(:final replyToMessageId?)) {
      final original = _controller!.messages.where((candidate) => candidate.id == replyToMessageId).firstOrNull;
      if (original is TextMessage) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '↩ ${original.text}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: Chat(
        currentUserId: _me,
        chatController: _controller!,
        resolveUser: _resolveUser,
        onMessageSend: _send,
        // Bubbles and composer from our ColorScheme/TextTheme (light + dark).
        theme: ChatTheme.fromThemeData(theme),
        timeFormat: DateFormat.Hm(Localizations.localeOf(context).toString()),
        builders: Builders(
          // The package's strings are English-only → pass localized widgets.
          composerBuilder: (context) => Composer(
            hintText: l10n.chatHint,
            topWidget: _botTyping
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const IsTypingIndicator(),
                        const SizedBox(width: 8),
                        Text(l10n.chatTyping, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : null,
          ),
          emptyChatListBuilder: (context) => EmptyChatList(text: l10n.chatEmpty),
          // Only text has a default builder; image/file/video messages need one (or the flyer_chat_* packages).
          imageMessageBuilder: (context, message, index, {required isSentByMe, groupStatus}) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 240,
              child: AspectRatio(
                aspectRatio: (message.width ?? 4) / (message.height ?? 3),
                child: Image.network(
                  message.source,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),
          chatMessageBuilder: (context, message, index, animation, child,
                  {isRemoved, required isSentByMe, groupStatus}) =>
              ChatMessage(
            message: message,
            index: index,
            animation: animation,
            isRemoved: isRemoved,
            groupStatus: groupStatus,
            topWidget: _replyQuote(message),
            child: child,
          ),
        ),
      ),
    );
  }
}
