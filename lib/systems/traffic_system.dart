import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../entities/traffic_vehicle.dart';
import '../entities/coin_pickup.dart';

class TrafficSystem {
  final List<TrafficVehicle> vehicles = [];
  final List<PickupItem> pickups = [];
  final math.Random _random = math.Random();

  double _nextSpawnZ = 600.0;
  double _nextPickupZ = 400.0;

  static const List<Color> _carColors = [
    Color(0xFF3A86FF), // Neon Blue
    Color(0xFFFF006E), // Hot Pink
    Color(0xFFFFBE0B), // Vibrant Gold
    Color(0xFF8338EC), // Purple
    Color(0xFF06D6A0), // Teal Mint
    Color(0xFFE63946), // Crimson
    Color(0xFFCBD5E1), // Silver Slate
  ];

  void reset() {
    vehicles.clear();
    pickups.clear();
    _nextSpawnZ = 600.0;
    _nextPickupZ = 400.0;
  }

  void update(double dt, double playerZ, double distance) {
    // 1. Move active traffic forward
    for (final v in vehicles) {
      v.update(dt);
    }

    // 2. Update coin spin
    for (final p in pickups) {
      p.update(dt);
    }

    // 3. Despawn vehicles & pickups far behind camera
    vehicles.removeWhere((v) => v.worldZ < (playerZ - 350.0));
    pickups.removeWhere((p) => p.worldZ < (playerZ - 350.0) || p.isCollected);

    // 4. Dynamic Traffic Spawner
    // Traffic density increases with distance
    final double spawnInterval = math.max(160.0, 360.0 - (distance * 0.08));

    while (_nextSpawnZ < playerZ + 2400.0) {
      _spawnTrafficRow(_nextSpawnZ, distance);
      _nextSpawnZ += spawnInterval + _random.nextDouble() * 120.0;
    }

    // 5. Pickups Spawner (Coins & Nitro)
    while (_nextPickupZ < playerZ + 2200.0) {
      _spawnPickupCluster(_nextPickupZ);
      _nextPickupZ += 280.0 + _random.nextDouble() * 200.0;
    }
  }

  void _spawnTrafficRow(double spawnZ, double distance) {
    // Pick 1 to 2 lanes to populate (leaving at least 2 lanes clear for overtaking!)
    final availableLanes = [0, 1, 2, 3];
    availableLanes.shuffle(_random);

    // Harder difficulty spawns up to 2 vehicles per wave
    final int countToSpawn = (distance > 1200 && _random.nextDouble() > 0.45) ? 2 : 1;

    for (int i = 0; i < countToSpawn; i++) {
      final lane = availableLanes[i];
      final typeIndex = _random.nextInt(TrafficType.values.length);
      final type = TrafficType.values[typeIndex];
      final color = _carColors[_random.nextInt(_carColors.length)];

      // Speeds vary between 70 and 130 km/h
      final baseSpeed = 75.0 + _random.nextDouble() * 45.0;

      vehicles.add(TrafficVehicle.create(
        laneIndex: lane,
        spawnZ: spawnZ + (_random.nextDouble() * 40.0),
        type: type,
        color: color,
        baseSpeed: baseSpeed,
      ));
    }
  }

  void _spawnPickupCluster(double spawnZ) {
    const laneCoords = [-140.0, -45.0, 45.0, 140.0];
    final laneX = laneCoords[_random.nextInt(laneCoords.length)];

    // 80% chance for 3-5 coins in a row, 20% chance for a Nitro Canister
    if (_random.nextDouble() < 0.22) {
      pickups.add(PickupItem(
        type: PickupType.nitro,
        worldX: laneX,
        worldZ: spawnZ,
      ));
    } else {
      // Line of 3 coins
      for (int i = 0; i < 3; i++) {
        pickups.add(PickupItem(
          type: PickupType.coin,
          worldX: laneX,
          worldZ: spawnZ + (i * 45.0),
        ));
      }
    }
  }
}
