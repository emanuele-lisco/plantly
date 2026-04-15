import 'package:flutter/material.dart';
part 'navigation_item.dart';

class PlantlyBottomNav extends StatelessWidget {
  const PlantlyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            selectedColor: colorScheme.primary,
            idleColor: colorScheme.onSurface.withOpacity(0.55),
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.local_florist_rounded,
            label: 'Giardino',
            selected: currentIndex == 1,
            selectedColor: colorScheme.primary,
            idleColor: colorScheme.onSurface.withOpacity(0.55),
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profilo',
            selected: currentIndex == 2,
            selectedColor: colorScheme.primary,
            idleColor: colorScheme.onSurface.withOpacity(0.55),
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}
