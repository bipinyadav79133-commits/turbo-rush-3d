enum UpgradeType {
  engine,
  acceleration,
  handling,
  brakes,
  nitro,
}

class UpgradeInfo {
  final UpgradeType type;
  final String title;
  final String description;
  final int maxLevel;
  final List<int> costs; // Cost per level

  const UpgradeInfo({
    required this.type,
    required this.title,
    required this.description,
    this.maxLevel = 5,
    required this.costs,
  });

  static const List<UpgradeInfo> allUpgrades = [
    UpgradeInfo(
      type: UpgradeType.engine,
      title: 'Engine Tuning',
      description: 'Increases top speed by +8 km/h per level.',
      costs: [300, 600, 1200, 2400, 5000],
    ),
    UpgradeInfo(
      type: UpgradeType.acceleration,
      title: 'Twin Turbo',
      description: 'Accelerates faster off the line and after turns.',
      costs: [250, 500, 1000, 2000, 4500],
    ),
    UpgradeInfo(
      type: UpgradeType.handling,
      title: 'Steering & Suspension',
      description: 'Sharper cornering and responsive lane changing.',
      costs: [200, 450, 900, 1800, 4000],
    ),
    UpgradeInfo(
      type: UpgradeType.brakes,
      title: 'Ceramic Brakes',
      description: 'Quick stopping distance to dodge high-speed traffic.',
      costs: [150, 350, 750, 1500, 3500],
    ),
    UpgradeInfo(
      type: UpgradeType.nitro,
      title: 'Nitro Booster',
      description: 'Expands nitro fuel capacity and boost potency.',
      costs: [350, 700, 1400, 2800, 6000],
    ),
  ];
}
