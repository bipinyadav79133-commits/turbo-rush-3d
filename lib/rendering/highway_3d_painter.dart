import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../entities/player_car.dart';
import '../entities/traffic_vehicle.dart';
import '../entities/coin_pickup.dart';
import 'perspective_camera.dart';

class Highway3DPainter extends CustomPainter {
  final PerspectiveCamera camera;
  final PlayerCar player;
  final List<TrafficVehicle> traffic;
  final List<PickupItem> pickups;
  final String theme; // 'cyber_night', 'sunset_highway', 'desert_canyon'
  final double nitroEffectIntensity; // 0.0 to 1.0

  Highway3DPainter({
    required this.camera,
    required this.player,
    required this.traffic,
    required this.pickups,
    required this.theme,
    required this.nitroEffectIntensity,
  });

  static const double roadWidth = 440.0;
  static const double segmentLength = 80.0;
  static const int drawDistanceSegments = 38;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSkyAndHorizon(canvas, size);
    _drawRoadAndScenery(canvas, size);
    _drawPickups(canvas, size);
    _drawTraffic(canvas, size);
    _drawPlayerCar(canvas, size);
    if (nitroEffectIntensity > 0.05) {
      _drawSpeedLines(canvas, size);
    }
  }

  // 1. SKY AND HORIZON BACKGROUND
  void _drawSkyAndHorizon(Canvas canvas, Size size) {
    final horizonY = size.height * 0.44;

    Gradient skyGrad;
    Color groundColor;

    if (theme == 'sunset_highway') {
      skyGrad = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1F0D3D), Color(0xFF6B114D), Color(0xFFFF7A00)],
      );
      groundColor = const Color(0xFF2B1321);
    } else if (theme == 'desert_canyon') {
      skyGrad = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF102A43), Color(0xFF2D4B66), Color(0xFFE28743)],
      );
      groundColor = const Color(0xFF382314);
    } else {
      // Cyber Night (Default)
      skyGrad = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF060913), Color(0xFF0F172A), Color(0xFF1E1B4B)],
      );
      groundColor = const Color(0xFF0A0F1D);
    }

    // Sky rectangle
    final skyPaint = Paint()..shader = skyGrad.createShader(Rect.fromLTWH(0, 0, size.width, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY), skyPaint);

    // Ground terrain rectangle
    final groundPaint = Paint()..color = groundColor;
    canvas.drawRect(Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY), groundPaint);

    // Distant Cyber City Skyline Silhouettes
    _drawCitySkyline(canvas, size, horizonY);
  }

  void _drawCitySkyline(Canvas canvas, Size size, double horizonY) {
    final buildingPaint = Paint()..color = const Color(0xFF121B2F);
    final windowPaint = Paint()..color = TurboTheme.neonCyan.withValues(alpha: 0.35);

    final random = math.Random(42);
    double x = 0;
    while (x < size.width) {
      final w = 35.0 + random.nextDouble() * 55.0;
      final h = 25.0 + random.nextDouble() * 70.0;
      final rect = Rect.fromLTWH(x, horizonY - h, w, h);
      canvas.drawRect(rect, buildingPaint);

      // Neon antenna or windows
      if (random.nextDouble() > 0.4) {
        canvas.drawRect(
          Rect.fromLTWH(x + w * 0.3, horizonY - h + 10, w * 0.4, 4),
          windowPaint,
        );
      }
      x += w + 8;
    }
  }

  // 2. HIGHWAY AND ROADSIDE SCENERY
  void _drawRoadAndScenery(Canvas canvas, Size size) {
    final int baseSegmentIndex = (camera.z / segmentLength).floor();

    for (int n = drawDistanceSegments; n >= 0; n--) {
      final int segIndex = baseSegmentIndex + n;
      final double z1 = segIndex * segmentLength;
      final double z2 = (segIndex + 1) * segmentLength;

      final p1 = camera.project(0.0, 0.0, z1, size);
      final p2 = camera.project(0.0, 0.0, z2, size);

      if (!p1.isVisible && !p2.isVisible) continue;

      final double w1 = roadWidth * p1.scale;
      final double w2 = roadWidth * p2.scale;

      final double shoulderW1 = w1 * 1.18;
      final double shoulderW2 = w2 * 1.18;

      final bool isAlt = (segIndex % 4 < 2);

      // Draw Rumble Strips / Road Shoulder
      final shoulderPaint = Paint()
        ..color = isAlt ? TurboTheme.rumbleRed : TurboTheme.rumbleWhite;

      final shoulderPath = Path()
        ..moveTo(p1.screenX - shoulderW1, p1.screenY)
        ..lineTo(p2.screenX - shoulderW2, p2.screenY)
        ..lineTo(p2.screenX + shoulderW2, p2.screenY)
        ..lineTo(p1.screenX + shoulderW1, p1.screenY)
        ..close();
      canvas.drawPath(shoulderPath, shoulderPaint);

      // Draw Asphalt Road Surface
      final roadPaint = Paint()
        ..color = isAlt ? TurboTheme.asphaltDark : TurboTheme.asphaltLight;

      final roadPath = Path()
        ..moveTo(p1.screenX - w1, p1.screenY)
        ..lineTo(p2.screenX - w2, p2.screenY)
        ..lineTo(p2.screenX + w2, p2.screenY)
        ..lineTo(p1.screenX + w1, p1.screenY)
        ..close();
      canvas.drawPath(roadPath, roadPaint);

      // Draw 3 Dashed Lane Lines (separating 4 lanes)
      if (isAlt) {
        final lanePaint = Paint()
          ..color = TurboTheme.laneMarker
          ..strokeWidth = math.max(1.5, 3.5 * p1.scale)
          ..style = PaintingStyle.stroke;

        for (int lane = 1; lane <= 3; lane++) {
          final double laneFactor = (lane / 4.0) * 2.0 - 1.0; // -0.5, 0.0, +0.5
          final double lx1 = p1.screenX + (w1 * laneFactor);
          final double lx2 = p2.screenX + (w2 * laneFactor);
          canvas.drawLine(Offset(lx1, p1.screenY), Offset(lx2, p2.screenY), lanePaint);
        }
      }

      // Draw Roadside Neon Lamp Posts (every 12 segments)
      if (segIndex % 12 == 0) {
        _drawStreetLamp(canvas, size, z1, p1, true);
        _drawStreetLamp(canvas, size, z1, p1, false);
      }
    }
  }

  void _drawStreetLamp(Canvas canvas, Size size, double worldZ, ProjectedPoint p, bool isLeft) {
    final double poleWorldX = isLeft ? -roadWidth * 0.72 : roadWidth * 0.72;
    final basePt = camera.project(poleWorldX, 0.0, worldZ, size);
    final topPt = camera.project(poleWorldX, 110.0, worldZ, size);

    if (!basePt.isVisible || !topPt.isVisible) return;

    final polePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = math.max(1.5, 3.0 * basePt.scale);

    canvas.drawLine(
      Offset(basePt.screenX, basePt.screenY),
      Offset(topPt.screenX, topPt.screenY),
      polePaint,
    );

    // Neon glowing lamp head
    final lampPaint = Paint()
      ..color = TurboTheme.neonCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(topPt.screenX, topPt.screenY), math.max(2.0, 5.0 * topPt.scale), lampPaint);
  }

  // 3. 3D FLOATING PICKUPS (COINS & NITRO)
  void _drawPickups(Canvas canvas, Size size) {
    for (final p in pickups) {
      if (p.isCollected) continue;

      final proj = camera.project(p.worldX, p.worldY, p.worldZ, size);
      if (!proj.isVisible) continue;

      final double r = 18.0 * proj.scale;
      if (r < 1.0) continue;

      if (p.type == PickupType.coin) {
        // Gold Coin
        final coinPaint = Paint()
          ..shader = RadialGradient(
            colors: [TurboTheme.neonGold, const Color(0xFFD48B00)],
          ).createShader(Rect.fromCircle(center: Offset(proj.screenX, proj.screenY), radius: r));

        canvas.drawCircle(Offset(proj.screenX, proj.screenY), r, coinPaint);

        // Rim highlight
        final rimPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, 2.0 * proj.scale);
        canvas.drawCircle(Offset(proj.screenX, proj.screenY), r * 0.75, rimPaint);
      } else {
        // Nitro Fuel Canister
        final nitroPaint = Paint()
          ..shader = const LinearGradient(
            colors: [TurboTheme.neonPink, TurboTheme.neonCyan],
          ).createShader(Rect.fromCircle(center: Offset(proj.screenX, proj.screenY), radius: r));

        final rect = Rect.fromCenter(center: Offset(proj.screenX, proj.screenY), width: r * 1.6, height: r * 2.2);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.4)), nitroPaint);
      }
    }
  }

  // 4. 3D TRAFFIC VEHICLES
  void _drawTraffic(Canvas canvas, Size size) {
    // Sort traffic back to front (painter's algorithm)
    final sortedTraffic = List<TrafficVehicle>.from(traffic)
      ..sort((a, b) => b.worldZ.compareTo(a.worldZ));

    for (final v in sortedTraffic) {
      final pRear = camera.project(v.worldX, v.worldY, v.worldZ, size);
      if (!pRear.isVisible) continue;

      final double w = v.width * pRear.scale;
      final double h = v.height * pRear.scale;

      if (w < 2.0 || h < 2.0) continue;

      _renderVehicleBox(canvas, pRear.screenX, pRear.screenY, w, h, v.bodyColor, pRear.scale);
    }
  }

  void _renderVehicleBox(Canvas canvas, double cx, double cy, double w, double h, Color bodyColor, double scale) {
    // Chassis Rect
    final chassisRect = Rect.fromCenter(center: Offset(cx, cy - h * 0.5), width: w, height: h);
    final chassisPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bodyColor, bodyColor.withValues(alpha: 0.75)],
      ).createShader(chassisRect);

    canvas.drawRRect(RRect.fromRectAndRadius(chassisRect, Radius.circular(w * 0.12)), chassisPaint);

    // Windshield / Roof
    final roofRect = Rect.fromCenter(center: Offset(cx, cy - h * 0.8), width: w * 0.72, height: h * 0.45);
    final roofPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(RRect.fromRectAndRadius(roofRect, Radius.circular(w * 0.08)), roofPaint);

    // Glowing Red Taillights
    final tailPaint = Paint()
      ..color = TurboTheme.neonRed
      ..style = PaintingStyle.fill;
    final tw = math.max(2.0, w * 0.22);
    final th = math.max(1.5, h * 0.20);
    final ty = cy - h * 0.35;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.35, ty), width: tw, height: th), const Radius.circular(2)), tailPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.35, ty), width: tw, height: th), const Radius.circular(2)), tailPaint);

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF020617);
    final ww = math.max(2.0, w * 0.18);
    final wh = math.max(3.0, h * 0.35);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - w * 0.46, cy), width: ww, height: wh), wheelPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + w * 0.46, cy), width: ww, height: wh), wheelPaint);
  }

  // 5. 3D PLAYER SPORTS CAR
  void _drawPlayerCar(Canvas canvas, Size size) {
    final proj = camera.project(player.worldX, player.worldY, player.worldZ, size);
    if (!proj.isVisible) return;

    final double cx = proj.screenX;
    final double cy = proj.screenY;
    final double scale = proj.scale;

    final double w = 72.0 * scale;
    final double h = 38.0 * scale;

    canvas.save();
    // Rotate canvas around car center for dynamic chassis banking tilt
    canvas.translate(cx, cy - h * 0.5);
    canvas.rotate(player.bodyTilt);

    // Underglow Neon Shadow
    final underglowPaint = Paint()
      ..color = player.model.primaryColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 8), width: w * 1.3, height: h * 0.6), underglowPaint);

    // Lower Chassis
    final bodyRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [player.model.primaryColor, player.model.accentColor],
      ).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.15)), bodyPaint);

    // Aerodynamic Roof & Tinted Windshield
    final cabinRect = Rect.fromCenter(center: Offset(0, -h * 0.45), width: w * 0.68, height: h * 0.55);
    final cabinPaint = Paint()..color = const Color(0xFF090D16);
    canvas.drawRRect(RRect.fromRectAndRadius(cabinRect, Radius.circular(w * 0.12)), cabinPaint);

    // Specular Glass Reflection
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.12, -h * 0.48), width: w * 0.28, height: h * 0.35), const Radius.circular(3)),
      glassPaint,
    );

    // GT Rear Spoiler Wing
    final spoilerPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h * 0.78), width: w * 0.95, height: math.max(3.0, h * 0.18)), const Radius.circular(2)),
      spoilerPaint,
    );
    // Spoiler Mounts
    canvas.drawRect(Rect.fromCenter(center: Offset(-w * 0.28, -h * 0.68), width: 3, height: h * 0.22), spoilerPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.28, -h * 0.68), width: 3, height: h * 0.22), spoilerPaint);

    // LED Taillights Bar
    final tailBarPaint = Paint()
      ..color = player.isBraking ? Colors.white : TurboTheme.neonRed
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h * 0.15), width: w * 0.85, height: math.max(2.0, h * 0.14)), const Radius.circular(2)),
      tailBarPaint,
    );

    // Exhaust Pipes
    final exhaustPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawCircle(Offset(-w * 0.25, h * 0.35), math.max(2.0, 4.0 * scale), exhaustPaint);
    canvas.drawCircle(Offset(w * 0.25, h * 0.35), math.max(2.0, 4.0 * scale), exhaustPaint);

    // Nitro Jet Flames
    if (player.isNitroActive) {
      final flamePaint = Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, TurboTheme.neonCyan, TurboTheme.neonPink],
        ).createShader(Rect.fromCircle(center: Offset(0, h * 0.6), radius: w * 0.4));

      final flamePath1 = Path()
        ..moveTo(-w * 0.28, h * 0.35)
        ..lineTo(-w * 0.22, h * 0.35)
        ..lineTo(-w * 0.25, h * (0.8 + math.Random().nextDouble() * 0.4))
        ..close();

      final flamePath2 = Path()
        ..moveTo(w * 0.22, h * 0.35)
        ..lineTo(w * 0.28, h * 0.35)
        ..lineTo(w * 0.25, h * (0.8 + math.Random().nextDouble() * 0.4))
        ..close();

      canvas.drawPath(flamePath1, flamePaint);
      canvas.drawPath(flamePath2, flamePaint);
    }

    // Rotating Alloy Wheels
    final wheelPaint = Paint()..color = const Color(0xFF020617);
    final rimPaint = Paint()..color = const Color(0xFF94A3B8);
    final ww = math.max(3.0, w * 0.16);
    final wh = math.max(4.0, h * 0.45);

    // Left Wheel
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-w * 0.48, h * 0.2), width: ww, height: wh), const Radius.circular(2)), wheelPaint);
    canvas.drawCircle(Offset(-w * 0.48, h * 0.2), ww * 0.3, rimPaint);

    // Right Wheel
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.48, h * 0.2), width: ww, height: wh), const Radius.circular(2)), wheelPaint);
    canvas.drawCircle(Offset(w * 0.48, h * 0.2), ww * 0.3, rimPaint);

    canvas.restore();
  }

  // 6. SPEED LINES EFFECT DURING NITRO
  void _drawSpeedLines(Canvas canvas, Size size) {
    final speedLinePaint = Paint()
      ..color = TurboTheme.neonCyan.withValues(alpha: 0.3 * nitroEffectIntensity)
      ..strokeWidth = 2.0;

    final random = math.Random(13);
    for (int i = 0; i < 20; i++) {
      final startX = size.width * (0.1 + random.nextDouble() * 0.8);
      final startY = size.height * (0.2 + random.nextDouble() * 0.7);
      final len = 60.0 + random.nextDouble() * 140.0;
      canvas.drawLine(Offset(startX, startY), Offset(startX, startY + len), speedLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant Highway3DPainter oldDelegate) => true;
}
