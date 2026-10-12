import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/car_model.dart';
import '../models/upgrade_model.dart';
import '../models/player_profile.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';

class GarageScreen extends StatefulWidget {
  final PlayerProfile profile;
  final VoidCallback onBack;

  const GarageScreen({
    super.key,
    required this.profile,
    required this.onBack,
  });

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default to currently selected car
    final idx = CarModel.allCars.indexWhere((c) => c.id == widget.profile.selectedCarId);
    if (idx != -1) _currentIndex = idx;
  }

  CarModel get _currentCar => CarModel.allCars[_currentIndex];

  void _selectCar(CarModel car) {
    if (widget.profile.isCarUnlocked(car.id)) {
      setState(() {
        widget.profile.selectedCarId = car.id;
      });
      SaveService.saveProfile(widget.profile);
      AudioService.instance.playButtonClick();
    }
  }

  void _buyCar(CarModel car) {
    if (widget.profile.coins >= car.price) {
      setState(() {
        widget.profile.coins -= car.price;
        widget.profile.unlockCar(car.id);
        widget.profile.selectedCarId = car.id;
      });
      SaveService.saveProfile(widget.profile);
      AudioService.instance.playCoinPickup();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${car.name} Unlocked & Selected!'),
          backgroundColor: TurboTheme.neonGreen,
        ),
      );
    } else {
      AudioService.instance.playCollision();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins to purchase this vehicle!'),
          backgroundColor: TurboTheme.neonRed,
        ),
      );
    }
  }

  void _upgradeStat(UpgradeInfo upgrade) {
    final currentLvl = widget.profile.getUpgradeLevel(_currentCar.id, upgrade.type.name);
    if (currentLvl >= upgrade.maxLevel) return;

    final cost = upgrade.costs[currentLvl];
    if (widget.profile.coins >= cost) {
      setState(() {
        widget.profile.coins -= cost;
        widget.profile.setUpgradeLevel(_currentCar.id, upgrade.type.name, currentLvl + 1);
      });
      SaveService.saveProfile(widget.profile);
      AudioService.instance.playCoinPickup();
    } else {
      AudioService.instance.playCollision();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins for this upgrade!'),
          backgroundColor: TurboTheme.neonRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = _currentCar;
    final isUnlocked = widget.profile.isCarUnlocked(car.id);
    final isSelected = widget.profile.selectedCarId == car.id;

    return Scaffold(
      backgroundColor: TurboTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back button, Title, Coin Balance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                  const Text(
                    'GARAGE & UPGRADES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TurboTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TurboTheme.neonGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: TurboTheme.neonGold, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.profile.coins}',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Vehicle Showcase Carousel Card
                  _buildCarShowcase(car, isUnlocked, isSelected),
                  const SizedBox(height: 16),

                  // Performance Stats with Progress Bars
                  _buildStatsSection(car),
                  const SizedBox(height: 20),

                  // Upgrade Tuning Shop
                  if (isUnlocked) ...[
                    const Text(
                      'PERFORMANCE UPGRADES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: TurboTheme.neonCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...UpgradeInfo.allUpgrades.map((u) => _buildUpgradeTile(u)),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarShowcase(CarModel car, bool isUnlocked, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TurboTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: car.primaryColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: car.primaryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Selector Controls (Left / Right Arrows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              ),
              Column(
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    car.subtitle,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: car.primaryColor),
                  ),
                ],
              ),
              IconButton(
                onPressed: _currentIndex < CarModel.allCars.length - 1 ? () => setState(() => _currentIndex++) : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Car Visual Representation
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [car.primaryColor.withValues(alpha: 0.3), Colors.transparent],
                radius: 0.8,
              ),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(220, 95),
                painter: _GarageCarPainter(color: car.primaryColor, accentColor: car.accentColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selection / Purchase Action
          if (isSelected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: TurboTheme.neonGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TurboTheme.neonGreen),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: TurboTheme.neonGreen, size: 16),
                  SizedBox(width: 6),
                  Text('ACTIVE VEHICLE', style: TextStyle(fontWeight: FontWeight.w900, color: TurboTheme.neonGreen)),
                ],
              ),
            ),
          ] else if (isUnlocked) ...[
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => _selectCar(car),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TurboTheme.neonCyan,
                  foregroundColor: const Color(0xFF090D16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('SELECT CAR', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ] else ...[
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () => _buyCar(car),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TurboTheme.neonGold,
                  foregroundColor: const Color(0xFF090D16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: Text('UNLOCK FOR ${car.price} COINS', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(CarModel car) {
    final engineLvl = widget.profile.getUpgradeLevel(car.id, 'engine');
    final accelLvl = widget.profile.getUpgradeLevel(car.id, 'acceleration');
    final handlLvl = widget.profile.getUpgradeLevel(car.id, 'handling');
    final brakeLvl = widget.profile.getUpgradeLevel(car.id, 'brakes');

    final maxSpeed = (car.baseMaxSpeed + engineLvl * 10).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TurboTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildStatRow('Top Speed', '$maxSpeed KM/H', (maxSpeed / 340.0).clamp(0.0, 1.0)),
          const SizedBox(height: 10),
          _buildStatRow('Acceleration', '${(car.baseAcceleration * 100).toInt()}%', car.baseAcceleration + (accelLvl * 0.04)),
          const SizedBox(height: 10),
          _buildStatRow('Handling', '${(car.baseHandling * 100).toInt()}%', car.baseHandling + (handlLvl * 0.04)),
          const SizedBox(height: 10),
          _buildStatRow('Braking', '${(car.baseBraking * 100).toInt()}%', car.baseBraking + (brakeLvl * 0.04)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, double fraction) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TurboTheme.textMuted)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(TurboTheme.neonCyan),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildUpgradeTile(UpgradeInfo upgrade) {
    final currentLvl = widget.profile.getUpgradeLevel(_currentCar.id, upgrade.type.name);
    final isMax = currentLvl >= upgrade.maxLevel;
    final cost = isMax ? 0 : upgrade.costs[currentLvl];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TurboTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(upgrade.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(
                      'LVL $currentLvl/${upgrade.maxLevel}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMax ? TurboTheme.neonGreen : TurboTheme.neonCyan),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(upgrade.description, style: const TextStyle(fontSize: 11, color: TurboTheme.textDim)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isMax)
            const Text('MAXED', style: TextStyle(fontWeight: FontWeight.w900, color: TurboTheme.neonGreen, fontSize: 12))
          else
            ElevatedButton(
              onPressed: () => _upgradeStat(upgrade),
              style: ElevatedButton.styleFrom(
                backgroundColor: TurboTheme.neonCyan.withValues(alpha: 0.15),
                foregroundColor: TurboTheme.neonCyan,
                side: const BorderSide(color: TurboTheme.neonCyan),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 14, color: TurboTheme.neonGold),
                  const SizedBox(width: 4),
                  Text('$cost', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GarageCarPainter extends CustomPainter {
  final Color color;
  final Color accentColor;

  _GarageCarPainter({required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.75;
    final h = size.height * 0.45;

    // Underglow Shadow
    final underglow = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 18), width: w * 1.2, height: h * 0.5), underglow);

    // Chassis
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final bodyPaint = Paint()
      ..shader = LinearGradient(colors: [color, accentColor]).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(14)), bodyPaint);

    // Roof & Tinted Windows
    final roofRect = Rect.fromCenter(center: Offset(cx, cy - h * 0.35), width: w * 0.65, height: h * 0.55);
    final roofPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(RRect.fromRectAndRadius(roofRect, const Radius.circular(10)), roofPaint);

    // GT Wing Spoiler
    final spoilerPaint = Paint()..color = const Color(0xFF020617);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - h * 0.75), width: w * 0.88, height: 7), const Radius.circular(3)), spoilerPaint);

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF020617);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.45, cy + h * 0.2), width: 14, height: 26), const Radius.circular(4)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.45, cy + h * 0.2), width: 14, height: 26), const Radius.circular(4)), wheelPaint);
  }

  @override
  bool shouldRepaint(covariant _GarageCarPainter oldDelegate) =>
      color != oldDelegate.color || accentColor != oldDelegate.accentColor;
}
