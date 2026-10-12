import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'speedometer.dart';
import 'nitro_meter.dart';

class GameHud extends StatelessWidget {
  final int score;
  final int coins;
  final double distance;
  final double speed;
  final double topSpeed;
  final double currentNitro;
  final double maxNitro;
  final bool isBoosting;
  final int comboMultiplier;
  final VoidCallback onPause;

  const GameHud({
    super.key,
    required this.score,
    required this.coins,
    required this.distance,
    required this.speed,
    required this.topSpeed,
    required this.currentNitro,
    required this.maxNitro,
    required this.isBoosting,
    required this.comboMultiplier,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Top Status Bar: Score, Distance, Coins, Pause
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score & Multiplier
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SCORE: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: TurboTheme.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (comboMultiplier > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TurboTheme.neonPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${comboMultiplier}X COMBO',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${distance.toInt()} M',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: TurboTheme.neonCyan,
                      ),
                    ),
                  ],
                ),

                // Center-Right: Coins & Pause
                Row(
                  children: [
                    // Coin Counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: TurboTheme.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TurboTheme.neonGold.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: TurboTheme.neonGold, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '$coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Pause Button
                    IconButton(
                      onPressed: onPause,
                      style: IconButton.styleFrom(
                        backgroundColor: TurboTheme.surface.withValues(alpha: 0.85),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Lower Bar: Speedometer & Nitro Meter (above touch buttons)
            Padding(
              padding: const EdgeInsets.only(bottom: 96),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SpeedometerWidget(currentSpeed: speed, topSpeed: topSpeed),
                  NitroMeterWidget(
                    currentNitro: currentNitro,
                    maxNitro: maxNitro,
                    isBoosting: isBoosting,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
