import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../messaging/presentation/new_conversation_sheet.dart';
import '../domain/location_fix.dart';
import 'location_controller.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.focus});

  /// Optional point to centre on, e.g. when opened from an SOS event.
  final LatLng? focus;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _map = MapController();
  bool _ready = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _recenter() async {
    final fix = await ref.read(locationControllerProvider.notifier).refresh();
    if (fix != null && _ready) {
      _map.move(LatLng(fix.latitude, fix.longitude), 16);
    }
  }

  Future<void> _share(LocationFix fix) async {
    final peer = await pickPeer(context, title: 'Share location with…');
    if (peer == null || !mounted) return;
    final ok = await confirmAction(
      context,
      title: 'Share your location?',
      message: 'Your coordinates will be sent to $peer.',
      confirmLabel: 'Share',
    );
    if (!ok || !mounted) return;
    final sent = await ref
        .read(messagingServiceProvider)
        .send(peerNodeId: peer, body: 'My current location', location: fix);
    if (mounted) context.go(AppRoutes.conversation(sent.conversationId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationControllerProvider);
    final latest = ref.watch(latestLocationProvider).value;
    final history = ref.watch(locationHistoryProvider).value ?? const [];
    final sos = ref.watch(sosEventsProvider).value ?? const [];

    final current = loc.fix ?? latest;
    final centre =
        widget.focus ??
        (current == null
            ? const LatLng(7.8731, 80.7718)
            : LatLng(current.latitude, current.longitude));
    final zoom = widget.focus != null || current != null ? 15.0 : 6.0;

    ref.listen(locationControllerProvider.select((s) => s.fix), (prev, next) {
      if (next != null && prev == null && widget.focus == null && _ready) {
        _map.move(LatLng(next.latitude, next.longitude), 16);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: centre,
              initialZoom: zoom,
              onMapReady: () => _ready = true,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: AppConstants.androidPackage,
                tileProvider: ref.watch(mapTileProviderProvider),
                // Tiles need Internet; when offline the map stays usable
                // without them, so tile errors are deliberately ignored.
                errorTileCallback: (tile, error, stackTrace) {},
              ),
              if (history.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        for (final f in history)
                          LatLng(f.latitude, f.longitude),
                      ],
                      strokeWidth: 4,
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.7),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final e in sos.where((e) => e.hasLocation && e.isActive))
                    Marker(
                      point: LatLng(e.latitude!, e.longitude!),
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.sos,
                        color: Theme.of(context).colorScheme.error,
                        size: 36,
                      ),
                    ),
                  if (current != null)
                    Marker(
                      point: LatLng(current.latitude, current.longitude),
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(blurRadius: 6, color: Colors.black38),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            left: Spacing.lg,
            right: Spacing.lg,
            bottom: Spacing.lg + 20,
            child: _LocationPanel(
              state: loc,
              fix: current,
              historyCount: history.length,
              onRecenter: _recenter,
              onShare: current == null ? null : () => _share(current),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPanel extends ConsumerWidget {
  const _LocationPanel({
    required this.state,
    required this.fix,
    required this.historyCount,
    required this.onRecenter,
    required this.onShare,
  });

  final LocationState state;
  final LocationFix? fix;
  final int historyCount;
  final VoidCallback onRecenter;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(locationControllerProvider.notifier);

    final blocked = switch (state.permission) {
      LocationPermissionState.denied => (
        'Location permission needed',
        'Allow location access to see where you are and attach it to messages and SOS alerts.',
        'Allow access',
        controller.requestPermission,
      ),
      LocationPermissionState.deniedForever => (
        'Location permission blocked',
        'Location access was permanently denied. Enable it in system settings.',
        'Open settings',
        controller.openSettings,
      ),
      LocationPermissionState.serviceDisabled => (
        'GPS is turned off',
        'Turn on location services on your phone to get a position fix.',
        'Try again',
        controller.requestPermission,
      ),
      _ => null,
    };

    return EcoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (blocked != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_off_outlined,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(blocked.$1, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(blocked.$2, style: theme.textTheme.bodySmall),
            const SizedBox(height: Spacing.md),
            FilledButton(onPressed: blocked.$4, child: Text(blocked.$3)),
          ] else if (fix == null) ...[
            Row(
              children: [
                const Icon(Icons.gps_not_fixed),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    state.isLoading
                        ? 'Getting GPS fix…'
                        : (state.error ?? 'No location yet'),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            FilledButton.icon(
              onPressed: state.isLoading ? null : onRecenter,
              icon: const Icon(Icons.my_location),
              label: const Text('Get my location'),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.gps_fixed),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    Formatters.coordinates(fix!.latitude, fix!.longitude),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 2),
              child: Text(
                '${Formatters.accuracy(fix!.accuracy)} · ${Formatters.relative(fix!.recordedAt)}'
                '${state.error != null ? '\n${state.error}' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading ? null : onRecenter,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Refresh'),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_location),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            if (historyCount > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final ok = await confirmAction(
                      context,
                      title: 'Clear location history?',
                      message:
                          'All $historyCount saved location points will be deleted from this phone.',
                      confirmLabel: 'Clear',
                      destructive: true,
                    );
                    if (ok) {
                      await ref.read(locationRepositoryProvider).clearHistory();
                    }
                  },
                  child: Text('Clear $historyCount saved points'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
