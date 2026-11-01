import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/app_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _name.text.trim();
    if (value.isEmpty) {
      showMessage(context, 'Name cannot be empty.');
      return;
    }
    await ref.read(userRepositoryProvider).updateDisplayName(value);
    if (mounted) showMessage(context, 'Profile saved.');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncValueView<UserProfile?>(
        value: profile,
        data: (p) {
          if (p == null) {
            return const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'No profile',
              message: 'The local profile could not be loaded.',
            );
          }
          if (!_seeded) {
            _name.text = p.displayName;
            _seeded = true;
          }
          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              TextField(
                controller: _name,
                maxLength: 40,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Display name'),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: Spacing.sm),
              FilledButton(onPressed: _save, child: const Text('Save')),
              const SectionHeader('Identity'),
              EcoCard(
                child: Column(
                  children: [
                    InfoRow(
                      'Node ID',
                      p.nodeId,
                      trailing: IconButton(
                        tooltip: 'Copy node ID',
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: p.nodeId),
                          );
                          if (context.mounted) {
                            showMessage(context, 'Node ID copied.');
                          }
                        },
                      ),
                    ),
                    InfoRow('Created', Formatters.dateTime(p.createdAt)),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Your node ID identifies this phone on the EcoLink network. Share it with travelling companions so they can message you.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
