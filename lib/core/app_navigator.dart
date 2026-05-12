import 'package:flutter/material.dart';

class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static void navigateReplace(String route, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        route,
            (_) => false,
        arguments: arguments,
      );
    });
  }

  static void push(String route, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(
      route,
      arguments: arguments,
    );
  }

  static void pushReplacement(String route, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(
      route,
      arguments: arguments,
    );
  }
}