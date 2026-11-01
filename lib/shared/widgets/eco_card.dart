import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Standard surface used across the app. Tappable when [onTap] is given.
class EcoCard extends StatelessWidget {
  const EcoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.color,
    this.borderColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      side: BorderSide(color: borderColor ?? scheme.outlineVariant),
    );
    final card = Material(
      color: color ?? scheme.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    return semanticLabel == null
        ? card
        : Semantics(container: true, label: semanticLabel, child: card);
  }
}
