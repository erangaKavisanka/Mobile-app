import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/app.dart';
import '../domain/message.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedPeer = 'NODE_B';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EcoLinkState>();
    final conversations = state.conversations;
    final selected =
        conversations.where((c) => c.peerId == _selectedPeer).firstOrNull ??
        conversations.firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Messaging')),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.horizontal,
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final selectedFlag =
                    conversation.peerId == (selected?.peerId ?? '');
                return ChoiceChip(
                  label: Text(conversation.peerId),
                  selected: selectedFlag,
                  onSelected: (_) =>
                      setState(() => _selectedPeer = conversation.peerId),
                );
              },
            ),
          ),
          Expanded(
            child: selected == null
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: selected.messages.length,
                    itemBuilder: (context, index) {
                      final message = selected.messages[index];
                      final sent = message.senderId == state.localNodeId;
                      return Align(
                        alignment: sent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sent
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: sent
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat.Hm().format(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: sent
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (sent)
                                    Icon(
                                      message.lifecycleStatus ==
                                              MessageLifecycleStatus.failed
                                          ? Icons.error_outline
                                          : Icons.done_all,
                                      size: 14,
                                      color: sent
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Send a message to the network',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) {
                      return;
                    }
                    final peer = selected?.peerId ?? _selectedPeer;
                    await state.sendMessage(text, peer);
                    _controller.clear();
                    setState(() => _selectedPeer = peer);
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
