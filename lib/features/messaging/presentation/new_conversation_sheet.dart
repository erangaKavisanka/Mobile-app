import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../devices/domain/node.dart';
import 'message_widgets.dart';

/// Lets the user pick a known node or type a node id. Returns the node id.
Future<String?> pickPeer(BuildContext context, {String title = 'New message'}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PeerSheet(title: title),
  );
}

class _PeerSheet extends ConsumerStatefulWidget {
  const _PeerSheet({required this.title});

  final String title;

  @override
  ConsumerState<_PeerSheet> createState() => _PeerSheetState();
}

class _PeerSheetState extends ConsumerState<_PeerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodesProvider);
    final local = ref.watch(localNodeIdProvider);
    final peers = (nodes.value ?? const <Node>[])
        .where((n) => !n.isGateway && n.nodeId != local)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Spacing.md),
          if (peers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.md),
              child: Text(
                'No nodes discovered yet. Connect to the gateway on the Devices tab, or enter a node ID below.',
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final n in peers)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: PeerAvatar(n.name),
                      title: Text(n.name),
                      subtitle: Text(n.nodeId),
                      trailing: n.isSimulated ? const SimulatedBadge() : null,
                      onTap: () => Navigator.pop(context, n.nodeId),
                    ),
                ],
              ),
            ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Or enter a node ID',
              hintText: 'e.g. ECO-1A2B3C',
            ),
            onSubmitted: _submit,
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _submit(_controller.text),
              child: const Text('Start conversation'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(String value) {
    final id = value.trim().toUpperCase();
    if (id.isEmpty) return;
    Navigator.pop(context, id);
  }
}

class NoNodesHint extends StatelessWidget {
  const NoNodesHint({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.forum_outlined,
    title: 'No conversations yet',
    message: 'Start a conversation with a nearby node. Messages are saved on this phone and sent when the gateway is connected.',
  );
}
