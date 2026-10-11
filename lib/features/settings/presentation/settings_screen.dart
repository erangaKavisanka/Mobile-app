import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nodeIdController;

  @override
  void initState() {
    super.initState();
    _nodeIdController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EcoLinkState>();
    _nodeIdController.text = state.localNodeId;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local node configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nodeIdController,
                    decoration: const InputDecoration(labelText: 'Node ID'),
                    onSubmitted: (value) {
                      final adjusted = value.trim().isEmpty
                          ? AppConstants.defaultNodeId
                          : value.trim();
                      state.localNodeId = adjusted;
                      state.log('Node ID updated to $adjusted');
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Demo mode'),
                    subtitle: const Text(
                      'Emulate USB and gateway behavior without hardware.',
                    ),
                    trailing: SizedBox(
                      width: 52,
                      child: Switch(
                        value: state.demoMode,
                        onChanged: (value) {
                          state.demoMode = value;
                          state.usbStatus = value
                              ? 'Demo mode'
                              : 'USB disconnected';
                          state.rfStatus = value ? 'Demo' : 'Nominal';
                          state.log('Demo mode switched to $value');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnostics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text('Protocol v${AppConstants.protocolVersion}'),
                  Text('Pending queue: ${state.pendingQueueCount}'),
                  Text('Synchronization: ${state.cloudStatus}'),
                  Text('Application version: ${AppConstants.appVersion}'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final data = utf8.encode(state.diagnosticSummary());
                      final clipboardData = ClipboardData(
                        text: String.fromCharCodes(data),
                      );
                      await Clipboard.setData(clipboardData);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Diagnostics copied to clipboard.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Export diagnostics'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('USB control'),
              subtitle: Text(state.usbStatus),
              trailing: Switch(
                value: state.usbConnected,
                onChanged: (value) {
                  state.usbConnected = value;
                  state.usbStatus = value ? 'Connected' : 'Disconnected';
                  state.log(
                    'USB status changed to ${value ? 'Connected' : 'Disconnected'}',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nodeIdController.dispose();
    super.dispose();
  }
}
