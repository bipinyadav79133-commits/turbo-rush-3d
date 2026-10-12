import 'package:flutter/material.dart';

class CarModel {
  final String id;
  final String name;
  final String subtitle;
  final int price;
  final Color primaryColor;
  final Color accentColor;
  final double baseMaxSpeed; // in km/h
  final double baseAcceleration; // 0.0 - 1.0
  final double baseHandling; // 0.0 - 1.0
  final double baseBraking; // 0.0 - 1.0
  final double baseNitroCapacity; // seconds

  const CarModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.primaryColor,
    required this.accentColor,
    required this.baseMaxSpeed,
    required this.baseAcceleration,
    required this.baseHandling,
    required this.baseBraking,
    required this.baseNitroCapacity,
  });

  static const List<CarModel> allCars = [
    CarModel(
      id: 'apex_cruiser',
      name: 'Apex Cruiser',
      subtitle: 'Starter Sports Car',
      price: 0, // Free starter
      primaryColor: Color(0xFF00F2FE),
      accentColor: Color(0xFF4FACFE),
      baseMaxSpeed: 180.0,
      baseAcceleration: 0.60,
      baseHandling: 0.70,
      baseBraking: 0.65,
      baseNitroCapacity: 5.0,
    ),
    CarModel(
      id: 'venom_gt',
      name: 'Venom GT',
      subtitle: 'Street Racer',
      price: 1500,
      primaryColor: Color(0xFF00FF87),
      accentColor: Color(0xFF60EFFF),
      baseMaxSpeed: 215.0,
      baseAcceleration: 0.72,
      baseHandling: 0.78,
      baseBraking: 0.70,
      baseNitroCapacity: 6.5,
    ),
    CarModel(
      id: 'phantom_v8',
      name: 'Phantom V8',
      subtitle: 'Muscle Beast',
      price: 3500,
      primaryColor: Color(0xFFFFB703),
      accentColor: Color(0xFFFB8500),
      baseMaxSpeed: 240.0,
      baseAcceleration: 0.85,
      baseHandling: 0.65,
      baseBraking: 0.75,
      baseNitroCapacity: 8.0,
    ),
    CarModel(
      id: 'vortex_r',
      name: 'Vortex R',
      subtitle: 'Precision Supercar',
      price: 7000,
      primaryColor: Color(0xFFF72585),
      accentColor: Color(0xFF7209B7),
      baseMaxSpeed: 275.0,
      baseAcceleration: 0.90,
      baseHandling: 0.88,
      baseBraking: 0.85,
      baseNitroCapacity: 9.5,
    ),
    CarModel(
      id: 'hyperion_evo',
      name: 'Hyperion Evo',
      subtitle: 'Apex Hypercar',
      price: 15000,
      primaryColor: Color(0xFFFF3366),
      accentColor: Color(0xFFFFCC00),
      baseMaxSpeed: 320.0,
      baseAcceleration: 0.98,
      baseHandling: 0.95,
      baseBraking: 0.95,
      baseNitroCapacity: 12.0,
    ),
  ];

  static CarModel getById(String id) {
    return allCars.firstWhere(
      (c) => c.id == id,
      orElse: () => allCars.first,
    );
  }
}
