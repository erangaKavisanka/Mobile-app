import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/app.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EcoLinkState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS activation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activates an emergency event without contacting external responders automatically.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      await state.activateSos();
                    },
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Activate SOS'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...state.sosHistory.map((event) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.eventId,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: event.isActive
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            event.status,
                            style: TextStyle(
                              color: event.isActive
                                  ? Colors.red.shade800
                                  : Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Source: ${event.sourceNodeId}'),
                    Text(
                      'Created: ${DateFormat('MMM d, yyyy · HH:mm').format(event.createdAt)}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acknowledgements: ${event.acknowledgementHistory.join(', ')}',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await state.resolveSos(event.eventId);
                          },
                          child: const Text('Resolve'),
                        ),
                        const SizedBox(width: 8),
                        Text(event.isActive ? 'Pending response' : 'Resolved'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
