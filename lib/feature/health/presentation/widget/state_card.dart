import 'package:flutter/material.dart';
import 'package:hubo/core/constants/palette.dart';
import 'package:lottie/lottie.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.asset,
  }) : super(key: key);

  final String title;
  final String value;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Palette.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🔥 Animated Icon
            SizedBox(
              width: 40,
              height: 40,
              child: Lottie.asset(asset, repeat: true, fit: BoxFit.contain),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
