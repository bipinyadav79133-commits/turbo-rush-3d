import 'package:flutter/material.dart';
import '../app/theme.dart';

class SpeedometerWidget extends StatelessWidget {
  final double currentSpeed;
  final double topSpeed;

  const SpeedometerWidget({
    super.key,
    required this.currentSpeed,
    required this.topSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final speedInt = currentSpeed.toInt();
    final pct = (currentSpeed / topSpeed).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: TurboTheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TurboTheme.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: TurboTheme.cyanGlow(blur: 10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$speedInt',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'KM/H',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: TurboTheme.neonCyan,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Speed gauge mini bar
          Container(
            width: 70,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  gradient: TurboTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
