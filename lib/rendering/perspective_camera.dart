import 'dart:ui';

class ProjectedPoint {
  final double screenX;
  final double screenY;
  final double scale;
  final bool isVisible;

  const ProjectedPoint({
    required this.screenX,
    required this.screenY,
    required this.scale,
    required this.isVisible,
  });
}

class PerspectiveCamera {
  double x;
  double y;
  double z;
  double depth; // Distance from camera to screen projection plane
  double fovMultiplier; // Dynamic FOV expansion during nitro

  PerspectiveCamera({
    this.x = 0.0,
    this.y = 180.0, // Eye height above highway
    this.z = -260.0, // Chase distance behind player car
    this.depth = 0.90,
    this.fovMultiplier = 1.0,
  });

  /// Project a 3D point (worldX, worldY, worldZ) into 2D viewport coordinates
  ProjectedPoint project(
    double worldX,
    double worldY,
    double worldZ,
    Size viewport,
  ) {
    final double relativeZ = worldZ - z;

    // Behind camera or too close
    if (relativeZ <= 5.0) {
      return const ProjectedPoint(
        screenX: 0.0,
        screenY: 0.0,
        scale: 0.0,
        isVisible: false,
      );
    }

    final double effectiveDepth = depth * fovMultiplier;
    final double scale = effectiveDepth / (relativeZ / 300.0);

    final double halfWidth = viewport.width / 2;
    final double horizonY = viewport.height * 0.44; // Vanishing horizon line

    final double screenX = halfWidth + (worldX - x) * scale;
    final double screenY = horizonY - (worldY - y) * scale;

    return ProjectedPoint(
      screenX: screenX,
      screenY: screenY,
      scale: scale,
      isVisible: true,
    );
  }
}
