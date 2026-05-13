import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
part 'navigation_item.dart';

/// Bottom navigation bar di Plantly — dark botanical.
///
/// La nav è volutamente più chiara dello sfondo canvas (#0E1612)
/// per emergere visivamente senza essere verde saturo.
/// Usa surface2 (#242B27) + bordo midGreen sottile + ombra nera.
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        // surface2: abbastanza diverso da canvas da essere leggibile,
        // ma non verde saturo — è grigio-forest neutro.
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          // Ombra nera principale — crea separazione fisica dallo sfondo.
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          // Alone verde sottolineato — sottile, non invasivo.
          BoxShadow(
            color: LightTheme.accent.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.local_florist_rounded,
            label: 'Giardino',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Cerca',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profilo',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}
