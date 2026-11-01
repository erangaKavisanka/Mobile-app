import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

enum PillTone { success, warning, danger, info, neutral, simulated }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.icon,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.status;
    final (fg, bg) = switch (tone) {
      PillTone.success => (c.success, c.successContainer),
      PillTone.warning => (c.warning, c.warningContainer),
      PillTone.danger => (c.danger, c.dangerContainer),
      PillTone.info => (c.info, c.infoContainer),
      PillTone.neutral => (c.neutral, c.neutralContainer),
      PillTone.simulated => (c.simulated, c.simulatedContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: Spacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium!
                  .copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marks any value that comes from the simulator rather than real hardware.
class SimulatedBadge extends StatelessWidget {
  const SimulatedBadge({super.key, this.label = 'SIMULATED'});

  final String label;

  @override
  Widget build(BuildContext context) => StatusPill(
    label: label,
    tone: PillTone.simulated,
    icon: Icons.science_outlined,
  );
}
