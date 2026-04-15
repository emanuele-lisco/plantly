import 'package:flutter/material.dart';

import '../../features/enumType.dart';

class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.strength});
  final Strength strength;

  static const _width = 60.0;
  static const _height = 5.0;
  static const _padding = 4.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(4),
            child: Text("FORZA PASSWORD",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Container(
                  height: _height,
                  width: _width,
                  decoration: BoxDecoration(
                    color: switch (strength) {
                      Strength.empty => Colors.grey,
                      Strength.weak => Colors.red,
                      Strength.medium => Colors.orange,
                      Strength.strong => Colors.green,
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Container(
                  height: _height,
                  width: _width,
                  decoration: BoxDecoration(
                    color: switch (strength) {
                      Strength.empty => Colors.grey,
                      Strength.weak => Colors.grey,
                      Strength.medium => Colors.orange,
                      Strength.strong => Colors.green,
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Container(
                  height: _height,
                  width: _width,
                  decoration: BoxDecoration(
                    color: switch (strength) {
                      Strength.empty => Colors.grey,
                      Strength.weak => Colors.grey,
                      Strength.medium => Colors.orange,
                      Strength.strong => Colors.green,
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Container(
                  height: _height,
                  width: _width,
                  decoration: BoxDecoration(
                    color: switch (strength) {
                      Strength.empty => Colors.grey,
                      Strength.weak => Colors.grey,
                      Strength.medium => Colors.grey,
                      Strength.strong => Colors.green,
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
                strength == Strength.empty
                    ? ""
                    : strength == Strength.weak
                        ? "Password debole"
                        : strength == Strength.medium
                            ? "Password media"
                            : "Password forte",
                style: TextStyle(
                    color: switch (strength) {
                      Strength.empty => Colors.grey,
                      Strength.weak => Colors.red,
                      Strength.medium => Colors.orange,
                      Strength.strong => Colors.green,
                    },
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
