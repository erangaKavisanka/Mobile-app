import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../location/presentation/location_controller.dart';
import '../domain/message.dart';
import 'message_widgets.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(messageRepositoryProvider)
          .markConversationRead(widget.conversationId),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send({bool withLocation = false}) async {
    final conversation = ref
        .read(conversationProvider(widget.conversationId))
        .value;
    if (conversation == null || _sending) return;
    final text = _controller.text.trim();
    if (text.isEmpty && !withLocation) return;

    setState(() => _sending = true);
    try {
      final location = withLocation
          ? await ref.read(locationControllerProvider.notifier).refresh()
          : null;
      if (withLocation && location == null) {
        if (mounted) {
          showMessage(
            context,
            'No GPS fix available, so no location was shared.',
          );
        }
        return;
      }
      await ref
          .read(messagingServiceProvider)
          .send(
            peerNodeId: conversation.peerNodeId,
            body: text.isEmpty ? 'My current location' : text,
            location: location,
          );
      _controller.clear();
      ref
          .read(messageRepositoryProvider)
          .markConversationRead(widget.conversationId);
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _shareLocation() async {
    final ok = await confirmAction(
      context,
      title: 'Share your location?',
      message: 'Your current GPS coordinates will be attached to this message and visible to the recipient.',
      confirmLabel: 'Share location',
    );
    if (ok) await _send(withLocation: true);
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider(widget.conversationId));
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final node = ref
        .watch(nodesProvider)
        .value
        ?.where((n) => n.nodeId == conversation.value?.peerNodeId)
        .firstOrNull;

    ref.listen(messagesProvider(widget.conversationId), (prev, next) {
      if ((next.value?.length ?? 0) > (prev?.value?.length ?? 0)) {
        ref
            .read(messageRepositoryProvider)
            .markConversationRead(widget.conversationId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            PeerAvatar(conversation.value?.title ?? '?', radius: 18),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.value?.title ?? 'Conversation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    conversation.value?.peerNodeId ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (node?.isSimulated ?? false) const SimulatedBadge(),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueView<List<Message>>(
              value: messages,
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'No messages yet',
                      message: 'Write a message below. It is saved on this phone first and sent when the gateway is connected.',
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(Spacing.lg),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _Bubble(
                        message: list[i],
                        showDay:
                            i == 0 ||
                            !_sameDay(list[i - 1].createdAt, list[i].createdAt),
                        onRetry: () => ref
                            .read(messagingServiceProvider)
                            .retry(list[i].id),
                      ),
                    ),
            ),
          ),
          _Composer(
            controller: _controller,
            sending: _sending,
            onSend: _send,
            onShareLocation: _shareLocation,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    final x = a.toLocal(), y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onShareLocation,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onShareLocation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.sm,
            Spacing.sm,
            Spacing.sm,
            Spacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Share my location',
                onPressed: sending ? null : onShareLocation,
                icon: const Icon(Icons.my_location),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Write a message',
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              IconButton.filled(
                tooltip: 'Send message',
                onPressed: sending ? null : onSend,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.showDay,
    required this.onRetry,
  });

  final Message message;
  final bool showDay;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = message.isOutgoing;
    final fg = mine ? scheme.onPrimary : scheme.onSurface;
    final bg = mine ? scheme.primary : scheme.surfaceContainer;
    final failed = message.status == MessageStatus.failed;

    return Column(
      children: [
        if (showDay)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Text(
              Formatters.dateTime(message.createdAt).split(',').first,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
              padding: const EdgeInsets.fromLTRB(
                Spacing.md + 2,
                Spacing.sm + 2,
                Spacing.md + 2,
                Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(Radii.md),
                  topRight: const Radius.circular(Radii.md),
                  bottomLeft: Radius.circular(mine ? Radii.md : 4),
                  bottomRight: Radius.circular(mine ? 4 : Radii.md),
                ),
                border: failed
                    ? Border.all(color: scheme.error, width: 1.5)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: theme.textTheme.bodyLarge?.copyWith(color: fg),
                  ),
                  if (message.hasLocation) ...[
                    const SizedBox(height: Spacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place, size: 16, color: fg),
                        const SizedBox(width: Spacing.xs),
                        Flexible(
                          child: Text(
                            '${Formatters.coordinates(message.latitude!, message.longitude!)} · ${Formatters.accuracy(message.locationAccuracy)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: Spacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.time(message.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: fg.withValues(alpha: 0.75),
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: Spacing.xs),
                        MessageStatusIcon(
                          message.status,
                          color: fg.withValues(alpha: 0.85),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (mine)
          Align(
            alignment: Alignment.centerRight,
            child: failed
                ? TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text('${message.failureReason ?? 'Failed'} · Retry'),
                  )
                : message.status == MessageStatus.delivered
                ? const SizedBox.shrink()
                : Text(
                    statusInfo(message.status).label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
          ),
      ],
    );
  }
}
