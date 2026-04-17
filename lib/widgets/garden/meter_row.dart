
import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class MeterRow extends StatelessWidget {
  const MeterRow({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text('$value%', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value / 100,
            backgroundColor: Colors.black.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= 70 ? LightTheme.primary : const Color(0xFFB78A62),
            ),
          ),
        ),
      ],
    );
  }
}
