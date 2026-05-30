import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auto_irrigation_settings/auto_irrigation_settings_cubit.dart';
import '../../features/smart_pot/smart_pot_config.dart';
import '../../features/theme/models/theme.dart';
import '../feedback/snackbar_helper.dart';

/// Card di configurazione della modalità automatica.
///
/// Salva solo i parametri su Firestore. Non genera comandi automatici,
/// non implementa meteo e non contiene algoritmo decisionale avanzato.
class AutoIrrigationSettingsCard extends StatelessWidget {
  const AutoIrrigationSettingsCard({
    super.key,
    required this.deviceId,
    this.watering,
  });

  final String? deviceId;

  /// Fabbisogno idrico della pianta, se disponibile dai dati Perenual/Garden.
  /// Usato solo per proporre default prudenti, non per irrigare automaticamente.
  final String? watering;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutoIrrigationSettingsCubit, AutoIrrigationSettingsState>(
      listener: (context, state) {
        if (state is AutoIrrigationSettingsSuccess) {
          SnackBarHelper.showSuccess(context, state.message);
        }

        if (state is AutoIrrigationSettingsFailure) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return switch (state) {
          AutoIrrigationSettingsInitial() || AutoIrrigationSettingsLoading() =>
          const _AutoSettingsLoadingCard(),
          AutoIrrigationSettingsLoaded(config: final config) =>
              _AutoSettingsForm(
                deviceId: deviceId,
                watering: watering,
                config: config,
                isSaving: false,
              ),
          AutoIrrigationSettingsSaving(config: final config) =>
              _AutoSettingsForm(
                deviceId: deviceId,
                watering: watering,
                config: config,
                isSaving: true,
              ),
          AutoIrrigationSettingsSuccess(config: final config) =>
              _AutoSettingsForm(
                deviceId: deviceId,
                watering: watering,
                config: config,
                isSaving: false,
              ),
          AutoIrrigationSettingsFailure(
          message: final message,
          config: final config,
          ) => config == null
              ? _AutoSettingsErrorCard(
            message: message,
            onRetry: () => context
                .read<AutoIrrigationSettingsCubit>()
                .load(deviceId),
          )
              : _AutoSettingsForm(
            deviceId: deviceId,
            watering: watering,
            config: config,
            isSaving: false,
            errorMessage: message,
          ),
        };
      },
    );
  }
}

class _AutoSettingsLoadingCard extends StatelessWidget {
  const _AutoSettingsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: LightTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _AutoSettingsErrorCard extends StatelessWidget {
  const _AutoSettingsErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(
        borderColor: LightTheme.coral.withOpacity(0.30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: LightTheme.coral,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: LightTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
}

class _AutoSettingsForm extends StatefulWidget {
  const _AutoSettingsForm({
    required this.deviceId,
    required this.config,
    required this.isSaving,
    this.watering,
    this.errorMessage,
  });

  final String? deviceId;
  final SmartPotConfig config;
  final bool isSaving;
  final String? watering;
  final String? errorMessage;

  @override
  State<_AutoSettingsForm> createState() => _AutoSettingsFormState();
}

class _AutoSettingsFormState extends State<_AutoSettingsForm> {
  late bool _autoEnabled;
  late TextEditingController _thresholdController;
  late TextEditingController _cycleMlController;
  late TextEditingController _dailyMlController;

  @override
  void initState() {
    super.initState();
    _autoEnabled = widget.config.autoIrrigationEnabled;
    _thresholdController = TextEditingController(
      text: widget.config.soilMoistureThreshold.toStringAsFixed(0),
    );
    _cycleMlController = TextEditingController(
      text: widget.config.maxWaterMlPerCycle.toStringAsFixed(0),
    );
    _dailyMlController = TextEditingController(
      text: widget.config.maxWaterMlPerDay.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant _AutoSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _autoEnabled = widget.config.autoIrrigationEnabled;
      _thresholdController.text =
          widget.config.soilMoistureThreshold.toStringAsFixed(0);
      _cycleMlController.text = widget.config.maxWaterMlPerCycle.toStringAsFixed(0);
      _dailyMlController.text = widget.config.maxWaterMlPerDay.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _cycleMlController.dispose();
    _dailyMlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LightTheme.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: LightTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Irrigazione automatica',
                      style: textTheme.labelMedium?.copyWith(
                        color: LightTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _autoEnabled  ? 'Configura soglie e limiti. Per ora Plantly salva solo la configurazione.' : 'Attiva modalità automatica',
                      style: textTheme.bodySmall?.copyWith(
                        color: LightTheme.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _autoEnabled,
                activeThumbColor: LightTheme.primary,
                onChanged: widget.isSaving ? null : _onAutoChanged,
              ),
            ],
          ),
          if (!_autoEnabled) ...[
            const SizedBox(height: 12),
            _AutoDisabledHint(watering: widget.watering),
          ],
          if (_autoEnabled) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.isSaving ? null : _applyRecommendedSettings,
                icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                label: const Text('Usa valori consigliati'),
              ),
            ),
            const SizedBox(height: 12),
            _NumberField(
              controller: _thresholdController,
              enabled: !widget.isSaving,
              label: 'Soglia umidità minima',
              suffix: '%',
              icon: Icons.water_drop_rounded,
            ),
            const SizedBox(height: 10),
            _NumberField(
              controller: _cycleMlController,
              enabled: !widget.isSaving,
              label: 'Ml per ciclo',
              suffix: 'ml',
              icon: Icons.opacity_rounded,
            ),
            const SizedBox(height: 10),
            _NumberField(
              controller: _dailyMlController,
              enabled: !widget.isSaving,
              label: 'Massimo ml al giorno',
              suffix: 'ml',
              icon: Icons.calendar_today_rounded,
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.errorMessage!,
                style: textTheme.bodySmall?.copyWith(
                  color: LightTheme.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.isSaving ? null : _save,
                icon: widget.isSaving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LightTheme.primary,
                  ),
                )
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(widget.isSaving ? 'Salvataggio...' : 'Salva configurazione'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onAutoChanged(bool value) {
    if (value) {
      setState(() => _autoEnabled = true);
      return;
    }

    // Quando l'utente spegne la modalità automatica, salviamo subito il flag
    // disattivato. I campi vengono nascosti e non vengono creati comandi.
    _save(autoEnabledOverride: false);
  }

  void _applyRecommendedSettings() {
    context.read<AutoIrrigationSettingsCubit>().applyRecommendedSettings(
      currentConfig: widget.config.copyWith(autoIrrigationEnabled: true),
      watering: widget.watering,
    );
  }

  void _save({bool? autoEnabledOverride}) {
    final threshold = _parseDouble(_thresholdController.text);
    final cycleMl = _parseDouble(_cycleMlController.text);
    final dailyMl = _parseDouble(_dailyMlController.text);

    if (threshold == null || cycleMl == null || dailyMl == null) {
      SnackBarHelper.showError(
        context,
        'Inserisci valori numerici validi per la configurazione.',
      );
      return;
    }

    context.read<AutoIrrigationSettingsCubit>().saveSettings(
      deviceId: widget.deviceId,
      currentConfig: widget.config,
      autoIrrigationEnabled: autoEnabledOverride ?? _autoEnabled,
      soilMoistureThreshold: threshold,
      maxWaterMlPerCycle: cycleMl,
      maxWaterMlPerDay: dailyMl,
    );
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }
}

class _AutoDisabledHint extends StatelessWidget {
  const _AutoDisabledHint({this.watering});

  final String? watering;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cleanWatering = watering?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LightTheme.surface3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightTheme.border),
      ),
      child: Text(
        cleanWatering == null || cleanWatering.isEmpty
            ? 'Quando la attivi, puoi usare valori consigliati prudenti oppure inserirli manualmente.'
            : 'Quando la attivi, Plantly può proporre valori prudenti partendo dal fabbisogno idrico: $cleanWatering.',
        style: textTheme.bodySmall?.copyWith(
          color: LightTheme.textMuted,
          height: 1.3,
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.suffix,
    required this.icon,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }
}

BoxDecoration _cardDecoration({Color? borderColor}) {
  return BoxDecoration(
    color: LightTheme.surface1,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderColor ?? LightTheme.border),
  );
}
