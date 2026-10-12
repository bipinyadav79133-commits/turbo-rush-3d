class RoadSegment {
  final int index;
  final double worldZ;
  final double curve; // -1.0 (hard left) to +1.0 (hard right)
  final double elevation; // Hill height in world units
  final bool hasLightPost;
  final bool hasBillboard;
  final String? billboardText;
  final bool hasTree;

  const RoadSegment({
    required this.index,
    required this.worldZ,
    this.curve = 0.0,
    this.elevation = 0.0,
    this.hasLightPost = false,
    this.hasBillboard = false,
    this.billboardText,
    this.hasTree = false,
  });
}
