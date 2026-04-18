import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the currently selected tab index in [MainShellPage].
///
/// Moving this state out of MainShellPage's setState() means:
/// - The active tab index is observable from anywhere in the subtree.
/// - Tab selection can be driven externally (e.g. deep links, notifications).
/// - The page remains a StatelessWidget and is easier to test.
class ShellCubit extends Cubit<int> {
  ShellCubit() : super(0);

  /// Selects [index] as the active tab.
  /// No-ops if [index] is already selected.
  void selectTab(int index) {
    if (state == index) return;
    emit(index);
  }
}
