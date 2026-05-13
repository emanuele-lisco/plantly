part of 'plantly_bottom_navigation.dart';

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  // Accent verde brillante per lo stato attivo.
  static const _activeColor = LightTheme.accent;

  // Idle: grigio chiaro caldo — leggibile su surface2 scuro, NON verde.
  static const _idleColor = LightTheme.textSecondary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: LightTheme.accent.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? LightTheme.accent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icona con pill di sfondo quando attiva
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(selected ? 5 : 0),
                decoration: BoxDecoration(
                  color: selected
                      ? _activeColor.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? _activeColor : _idleColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected ? _activeColor : _idleColor,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                  fontFamily: 'Sora',
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
