import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/state_views.dart';
import '../../devices/domain/device_transport.dart';
import '../domain/message.dart';
import 'message_widgets.dart';
import 'new_conversation_sheet.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _search = TextEditingController();
  List<Message>? _results;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    final results = await ref.read(messageRepositoryProvider).search(query);
    if (mounted) setState(() => _results = results);
  }

  Future<void> _newConversation() async {
    final peer = await pickPeer(context);
    if (peer == null || !mounted) return;
    final conversation = await ref
        .read(messageRepositoryProvider)
        .getOrCreateConversation(peer);
    if (mounted) context.push(AppRoutes.conversation(conversation.id));
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final controls = ref.watch(simulationControlsProvider);
    final connected =
        ref.watch(connectionStateProvider).value ==
        TransportConnectionState.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          if (controls != null)
            IconButton(
              tooltip: connected ? 'Simulate an incoming message' : 'Connect the simulated gateway to receive simulated messages',
              icon: const Icon(Icons.science_outlined),
              onPressed: connected
                  ? () async {
                      await controls.simulateIncomingMessage();
                      if (context.mounted) {
                        showMessage(context, 'Simulated message incoming…');
                      }
                    }
                  : () => showMessage(
                      context,
                      'Connect the gateway on the Devices tab first.',
                    ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newConversation,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('New message'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.sm,
              Spacing.lg,
              Spacing.sm,
            ),
            child: TextField(
              controller: _search,
              onChanged: _runSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search messages',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          _runSearch('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: _results != null
                ? _SearchResults(results: _results!)
                : AsyncValueView<List<Conversation>>(
                    value: conversations,
                    data: (list) => list.isEmpty
                        ? const NoNodesHint()
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 96),
                            itemCount: list.length,
                            separatorBuilder: (_, _) =>
                                const Divider(indent: 76),
                            itemBuilder: (_, i) => _ConversationTile(list[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile(this.conversation);

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = conversation.unreadCount;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      leading: PeerAvatar(conversation.title),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: unread > 0 ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              Formatters.relative(conversation.lastMessageAt!),
              style: theme.textTheme.bodySmall,
            ),
          if (unread > 0) ...[
            const SizedBox(height: Spacing.xs),
            Badge(label: Text('$unread')),
          ],
        ],
      ),
      onTap: () => context.push(AppRoutes.conversation(conversation.id)),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results});

  final List<Message> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No matches',
        message: 'No saved message contains that text.',
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final m = results[i];
        return ListTile(
          title: Text(m.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${m.isOutgoing ? 'To ${m.recipientNodeId}' : 'From ${m.senderNodeId}'} · ${Formatters.dateTime(m.createdAt)}',
          ),
          onTap: () => context.push(AppRoutes.conversation(m.conversationId)),
        );
      },
    );
  }
}
