import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/app.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EcoLinkState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: state.nodes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final device = state.nodes[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: device.connectionStatus == 'linked'
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                child: Icon(
                  Icons.device_hub,
                  color: device.connectionStatus == 'linked'
                      ? Colors.green.shade900
                      : Colors.orange.shade900,
                ),
              ),
              title: Text(device.nodeId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${device.type}'),
                  Text('USB: ${device.connectionStatus}'),
                  Text(
                    'Last seen: ${DateFormat('MMM d, HH:mm').format(DateTime.parse(device.lastSeen))}',
                  ),
                  if (device.battery != null)
                    Text('Battery: ${device.battery!.toStringAsFixed(0)}%'),
                  if (device.rfStatus.isNotEmpty)
                    Text('RF status: ${device.rfStatus}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
