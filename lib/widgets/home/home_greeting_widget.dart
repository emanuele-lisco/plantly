import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Saluto iniziale nella Home — stile dark botanical.
///
/// In futuro può ricevere il nome utente reale dal ProfileCubit / AuthBloc.
class HomeGreetingWidget extends StatelessWidget {
  const HomeGreetingWidget({
    super.key,
    this.greeting = 'Bentornato 🌿',
    this.subtitle = 'Il tuo giardino virtuale',
  });

  final String greeting;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: textTheme.bodyLarge?.copyWith(
                  color: LightTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.displaySmall?.copyWith(
                  color: LightTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: LightTheme.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: LightTheme.midGreen.withOpacity(0.3),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.notifications_outlined,
                  color: LightTheme.textSecondary,
                  size: 22,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: LightTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
