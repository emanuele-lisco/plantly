import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.22),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: LightTheme.midGreen.withOpacity(0.15),
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}
