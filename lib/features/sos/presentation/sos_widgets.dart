import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_pill.dart';
import '../domain/sos_event.dart';

String sosStatusLabel(SosStatus s) => switch (s) {
  SosStatus.triggered => 'Saved — waiting for gateway',
  SosStatus.failed => 'Transmission failed',
  SosStatus.sentToGateway => 'Sent to gateway',
  SosStatus.acknowledged => 'Gateway acknowledged',
  SosStatus.propagated => 'Propagated',
  SosStatus.resolved => 'Resolved',
  SosStatus.cancelled => 'Cancelled',
};

class SosStatusPill extends StatelessWidget {
  const SosStatusPill(this.status, {super.key});

  final SosStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      SosStatus.triggered => PillTone.warning,
      SosStatus.failed => PillTone.danger,
      SosStatus.sentToGateway || SosStatus.acknowledged => PillTone.info,
      SosStatus.propagated => PillTone.danger,
      SosStatus.resolved => PillTone.success,
      SosStatus.cancelled => PillTone.neutral,
    };
    return StatusPill(label: sosStatusLabel(status), tone: tone);
  }
}

/// Vertical timeline of an event's lifecycle. Steps without a timestamp have
/// not happened yet and are shown as pending.
class SosTimeline extends StatelessWidget {
  const SosTimeline({super.key, required this.event, required this.isOwn});

  final SosEvent event;

  /// False for SOS events received from other nodes.
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final steps = <_Step>[
      if (isOwn) ...[
        _Step('Triggered on this phone', event.createdAt),
        _Step('Sent to gateway', event.sentAt),
        if (event.status == SosStatus.failed)
          _Step('Gateway could not transmit — retry needed', event.updatedAt),
        _Step(
          'Acknowledged by gateway',
          event.acknowledgedAt,
          simulated: event.isSimulated,
        ),
        _Step(
          event.nodesReached > 0
              ? 'Propagated to ${event.nodesReached} nodes'
              : 'Propagated to other nodes',
          event.propagatedAt,
          simulated: event.isSimulated,
        ),
      ] else ...[
        _Step('Broadcast by ${event.sourceNodeId}', event.createdAt),
        _Step(
          'Received by this phone',
          event.propagatedAt,
          simulated: event.isSimulated,
        ),
      ],
      if (event.status == SosStatus.cancelled)
        _Step('Cancelled', event.closedAt)
      else if (event.status == SosStatus.resolved)
        _Step('Resolved', event.closedAt),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepTile(steps[i], last: i == steps.length - 1),
      ],
    );
  }
}

class _Step {
  const _Step(this.label, this.at, {this.simulated = false});
  final String label;
  final DateTime? at;
  final bool simulated;
}

class _StepTile extends StatelessWidget {
  const _StepTile(this.step, {required this.last});

  final _Step step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = step.at != null;
    final color = done ? context.status.success : theme.colorScheme.outline;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: color,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: done
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          done ? Formatters.dateTime(step.at!) : 'Pending',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (step.simulated && done) const SimulatedBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmation before sending an SOS. Resolves to the optional note, or
/// null when the user backs out.
Future<String?> confirmSos(
  BuildContext context, {
  required bool attachLocation,
  required bool gatewayConnected,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SosConfirmDialog(
      attachLocation: attachLocation,
      gatewayConnected: gatewayConnected,
    ),
  );
}

class _SosConfirmDialog extends StatefulWidget {
  const _SosConfirmDialog({
    required this.attachLocation,
    required this.gatewayConnected,
  });

  final bool attachLocation;
  final bool gatewayConnected;

  @override
  State<_SosConfirmDialog> createState() => _SosConfirmDialogState();
}

class _SosConfirmDialogState extends State<_SosConfirmDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.sos, color: scheme.error, size: 36),
      title: const Text('Send SOS alert?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This broadcasts an emergency alert over the EcoLink network. It does not contact emergency services.',
            ),
            const SizedBox(height: Spacing.md),
            _Bullet(
              widget.attachLocation
                  ? 'Your GPS location will be attached if available.'
                  : 'Location sharing for SOS is turned off. No coordinates will be sent.',
            ),
            _Bullet(
              widget.gatewayConnected
                  ? 'Gateway is connected — the alert is sent immediately.'
                  : 'Gateway is not connected — the alert is saved and sent when it connects.',
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _note,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(context, _note.text),
          child: const Text('Send SOS'),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6, right: 8),
          child: Icon(Icons.circle, size: 6),
        ),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}
