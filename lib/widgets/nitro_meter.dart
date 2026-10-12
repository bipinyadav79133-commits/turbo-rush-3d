import 'package:flutter/material.dart';
import '../app/theme.dart';

class NitroMeterWidget extends StatelessWidget {
  final double currentNitro;
  final double maxNitro;
  final bool isBoosting;

  const NitroMeterWidget({
    super.key,
    required this.currentNitro,
    required this.maxNitro,
    required this.isBoosting,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (currentNitro / maxNitro).clamp(0.0, 1.0);

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TurboTheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBoosting ? TurboTheme.neonPink : TurboTheme.neonGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: isBoosting ? TurboTheme.pinkGlow(blur: 14) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NITRO ${isBoosting ? '⚡ BOOST' : ''}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isBoosting ? TurboTheme.neonPink : TurboTheme.neonGold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(pct * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isBoosting ? TurboTheme.nitroGradient : TurboTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
