import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../../devices/domain/device_transport.dart';
import '../../location/presentation/location_controller.dart';
import '../domain/sos_event.dart';
import 'sos_widgets.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  bool _busy = false;

  Future<void> _trigger() async {
    final prefs = ref.read(preferencesProvider).value;
    final connected =
        ref.read(connectionStateProvider).value ==
        TransportConnectionState.connected;
    final note = await confirmSos(
      context,
      attachLocation: prefs?.attachLocationToSos ?? true,
      gatewayConnected: connected,
    );
    if (note == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final location = await ref
          .read(locationControllerProvider.notifier)
          .captureForSos();
      final event = await ref
          .read(sosServiceProvider)
          .trigger(location: location, note: note);
      if (!mounted) return;
      showMessage(
        context,
        event.hasLocation
            ? 'SOS created with your location.'
            : 'SOS created without location.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(sosEventsProvider);
    final local = ref.watch(localNodeIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: AsyncValueView<List<SosEvent>>(
        value: events,
        data: (all) {
          final active = all.where((e) => e.isActive).toList();
          final history = all.where((e) => !e.isActive).toList();
          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              _SosButton(busy: _busy, onPressed: _trigger),
              const SizedBox(height: Spacing.lg),
              const _Disclaimer(),
              if (active.isNotEmpty) ...[
                const SectionHeader('Active'),
                for (final e in active)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: SosEventCard(
                      event: e,
                      isOwn: e.sourceNodeId == local,
                    ),
                  ),
              ],
              SectionHeader('History'),
              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.xl),
                  child: Text(
                    'Resolved and cancelled events will appear here.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final e in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: SosEventCard(
                      event: e,
                      isOwn: e.sourceNodeId == local,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: Spacing.md),
        Semantics(
          button: true,
          label: 'Send SOS emergency alert',
          child: Container(
            width: 216,
            height: 216,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.error.withValues(alpha: 0.12),
            ),
            child: Material(
              color: scheme.error,
              shape: const CircleBorder(),
              elevation: 6,
              shadowColor: scheme.error.withValues(alpha: 0.5),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: busy ? null : onPressed,
                child: Center(
                  child: busy
                      ? SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            color: scheme.onError,
                            strokeWidth: 3,
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SOS',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: scheme.onError,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                            ),
                            Text(
                              'Tap to send alert',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onError),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final c = context.status;
    return EcoCard(
      color: c.warningContainer,
      borderColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: c.warning),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              'EcoLink alerts travel over the EcoLink radio network only. They do not call emergency services. '
              'Acknowledgements marked SIMULATED come from the built-in simulator, not real hardware.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: c.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class SosEventCard extends ConsumerWidget {
  const SosEventCard({super.key, required this.event, required this.isOwn});

  final SosEvent event;
  final bool isOwn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return EcoCard(
      borderColor: event.isActive
          ? theme.colorScheme.error.withValues(alpha: 0.5)
          : null,
      onTap: () => context.push(AppRoutes.sosEvent(event.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sos,
                color: event.isActive
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  isOwn ? 'Your SOS' : 'SOS from ${event.sourceNodeId}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              SosStatusPill(event.status),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '${Formatters.dateTime(event.createdAt)} · '
            '${event.hasLocation ? Formatters.coordinates(event.latitude!, event.longitude!) : 'no location'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (event.isActive && isOwn) ...[
            if (event.status == SosStatus.failed) ...[
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ref.read(sosServiceProvider).retry(event.id),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry sending'),
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => cancelSos(context, ref, event),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => resolveSos(context, ref, event),
                    child: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> resolveSos(
  BuildContext context,
  WidgetRef ref,
  SosEvent event,
) async {
  final ok = await confirmAction(
    context,
    title: 'Mark as resolved?',
    message:
        'Use this when the emergency is over. The event is closed on this phone and queued for cloud sync. '
        'Other nodes are not notified over radio.',
    confirmLabel: 'Resolve',
  );
  if (ok) await ref.read(sosServiceProvider).resolve(event.id);
}

Future<void> cancelSos(
  BuildContext context,
  WidgetRef ref,
  SosEvent event,
) async {
  final ok = await confirmAction(
    context,
    title: 'Cancel this SOS?',
    message: 'Use this if the alert was sent by mistake. Nodes that already received it are not told it was cancelled.',
    confirmLabel: 'Cancel SOS',
    destructive: true,
  );
  if (ok) await ref.read(sosServiceProvider).cancel(event.id);
}
