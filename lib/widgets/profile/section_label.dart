import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: LightTheme.deepForest.withOpacity(0.45),
      ),
    );
  }
}
