import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: LightTheme.danger.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LightTheme.danger.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LightTheme.danger,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: LightTheme.danger,
              ),
              const SizedBox(width: 10),
              Text(
                'Esci dall\'account',
                style: textTheme.titleMedium?.copyWith(
                  color: LightTheme.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}