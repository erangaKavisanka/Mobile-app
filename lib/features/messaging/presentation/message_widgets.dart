import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/message.dart';

class MessageStatusInfo {
  const MessageStatusInfo(this.label, this.icon);
  final String label;
  final IconData icon;
}

MessageStatusInfo statusInfo(MessageStatus s) => switch (s) {
  MessageStatus.local => const MessageStatusInfo(
    'Saved on phone',
    Icons.save_outlined,
  ),
  MessageStatus.queued => const MessageStatusInfo(
    'Queued — waiting for gateway',
    Icons.schedule,
  ),
  MessageStatus.sentToGateway => const MessageStatusInfo(
    'Sent to gateway — not yet confirmed',
    Icons.check,
  ),
  MessageStatus.delivered => const MessageStatusInfo(
    'Delivered (acknowledged)',
    Icons.done_all,
  ),
  MessageStatus.failed => const MessageStatusInfo(
    'Failed',
    Icons.error_outline,
  ),
};

class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon(this.status, {super.key, this.color});

  final MessageStatus status;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final info = statusInfo(status);
    final c = context.status;
    final tint = status == MessageStatus.failed
        ? Theme.of(context).colorScheme.error
        : status == MessageStatus.delivered
        ? c.success
        : color;
    return Semantics(
      label: info.label,
      child: Icon(info.icon, size: 16, color: tint),
    );
  }
}

/// Round avatar showing the peer's initial.
class PeerAvatar extends StatelessWidget {
  const PeerAvatar(this.title, {super.key, this.radius = 22});

  final String title;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = title.isEmpty ? '?' : title.characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary.withValues(alpha: 0.14),
      child: Text(
        initial,
        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}
