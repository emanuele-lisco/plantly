import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.hint = 'Cerca una pianta…',
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: LightTheme.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: LightTheme.midGreen.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            autofocus: autofocus,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: textTheme.bodyLarge?.copyWith(
              color: LightTheme.textPrimary,
            ),
            cursorColor: LightTheme.accent,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: LightTheme.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: LightTheme.sage,
                size: 22,
              ),
              suffixIcon: hasText
                  ? IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: LightTheme.textMuted,
                  size: 20,
                ),
                tooltip: 'Cancella',
              )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        );
      },
    );
  }
}