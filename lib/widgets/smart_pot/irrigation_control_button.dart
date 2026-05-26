import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/irrigation_control/irrigation_control_cubit.dart';
import '../../features/theme/models/theme.dart';
import '../feedback/snackbar_helper.dart';

/// Bottone manuale "Annaffia ora".
///
/// Non parla direttamente con Arduino: chiama [IrrigationControlCubit], che
/// valida lo stato del device e crea un comando pending su Firestore.
class IrrigationControlButton extends StatelessWidget {
  const IrrigationControlButton({
    super.key,
    required this.deviceId,
    required this.requestedBy,
  });

  final String? deviceId;
  final String requestedBy;

  bool get _hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IrrigationControlCubit, IrrigationControlState>(
      listener: (context, state) {
        if (state is IrrigationControlSuccess) {
          SnackBarHelper.showSuccess(context, state.message);
        }

        if (state is IrrigationControlFailure) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is IrrigationControlLoading;

        return ElevatedButton.icon(
          onPressed: !_hasDevice || isLoading
              ? null
              : () => context
                  .read<IrrigationControlCubit>()
                  .requestManualIrrigation(
                    deviceId: deviceId,
                    requestedBy: requestedBy,
                  ),
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.water_drop_rounded, size: 16),
          label: Text(
            isLoading
                ? 'Invio...'
                : _hasDevice
                    ? 'Annaffia ora'
                    : 'Vaso non collegato',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(42),
            backgroundColor: LightTheme.water,
            disabledBackgroundColor: LightTheme.border,
            disabledForegroundColor: LightTheme.textMuted,
          ),
        );
      },
    );
  }
}
