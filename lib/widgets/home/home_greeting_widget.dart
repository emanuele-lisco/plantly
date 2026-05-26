import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

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
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: t.bodyLarge?.copyWith(
                  color: LightTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: t.displaySmall?.copyWith(color: LightTheme.textPrimary),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: LightTheme.surface2,
            shape: BoxShape.circle,
            border: Border.all(color: LightTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
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
                    color: LightTheme.coral,
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