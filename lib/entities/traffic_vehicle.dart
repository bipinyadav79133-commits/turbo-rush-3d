import 'package:flutter/material.dart';

enum TrafficType {
  sedan,
  sports,
  suv,
  van,
  truck,
}

class TrafficVehicle {
  final TrafficType type;
  final int laneIndex; // 0, 1, 2, 3
  double worldX;
  double worldY;
  double worldZ;
  double speed; // In km/h
  final Color bodyColor;
  final double width;
  final double length;
  final double height;
  bool isOvertaken = false;
  bool get hasBeenOvertaken => isOvertaken;
  set hasBeenOvertaken(bool val) => isOvertaken = val;

  TrafficVehicle({
    required this.type,
    required this.laneIndex,
    required this.worldX,
    this.worldY = 0.0,
    required this.worldZ,
    required this.speed,
    required this.bodyColor,
    required this.width,
    required this.length,
    required this.height,
  });

  factory TrafficVehicle.create({
    required int laneIndex,
    required double spawnZ,
    required TrafficType type,
    required Color color,
    required double baseSpeed,
  }) {
    // 4 standard highway lanes: -140, -45, +45, +140
    const laneCoords = [-140.0, -45.0, 45.0, 140.0];
    final posX = laneCoords[laneIndex.clamp(0, 3)];

    double w = 48.0;
    double l = 95.0;
    double h = 34.0;
    double spd = baseSpeed;

    switch (type) {
      case TrafficType.sedan:
        w = 46.0;
        l = 92.0;
        h = 32.0;
        spd = baseSpeed * 0.95;
        break;
      case TrafficType.sports:
        w = 48.0;
        l = 96.0;
        h = 28.0;
        spd = baseSpeed * 1.25;
        break;
      case TrafficType.suv:
        w = 52.0;
        l = 104.0;
        h = 42.0;
        spd = baseSpeed * 0.90;
        break;
      case TrafficType.van:
        w = 54.0;
        l = 118.0;
        h = 50.0;
        spd = baseSpeed * 0.82;
        break;
      case TrafficType.truck:
        w = 58.0;
        l = 180.0; // Long semi-trailer
        h = 58.0;
        spd = baseSpeed * 0.70;
        break;
    }

    return TrafficVehicle(
      type: type,
      laneIndex: laneIndex,
      worldX: posX,
      worldZ: spawnZ,
      speed: spd,
      bodyColor: color,
      width: w,
      length: l,
      height: h,
    );
  }

  void update(double dt) {
    // Move forward at vehicle speed
    final double distancePerSec = (speed / 3.6) * 12.0;
    worldZ += distancePerSec * dt;
  }
}
