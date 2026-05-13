import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Label sezione — dark botanical.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: LightTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
    );
  }
}
