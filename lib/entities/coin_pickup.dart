enum PickupType {
  coin,
  nitro,
}

class PickupItem {
  final PickupType type;
  final double worldX;
  final double worldY;
  final double worldZ;
  bool isCollected = false;
  double rotation = 0.0;

  PickupItem({
    required this.type,
    required this.worldX,
    this.worldY = 16.0, // Floating above highway surface
    required this.worldZ,
  });

  void update(double dt) {
    rotation = (rotation + dt * 4.0); // Spin 4 rad/sec
  }
}
