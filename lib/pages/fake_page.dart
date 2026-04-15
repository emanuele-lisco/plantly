import 'package:flutter/material.dart';

class FakePage extends StatelessWidget {
  const FakePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          'prova',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}