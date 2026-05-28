import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plantly_app/cubits/session/session_cubit.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(SessionCubit sessionCubit) {
    _subscription = sessionCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<SessionState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}