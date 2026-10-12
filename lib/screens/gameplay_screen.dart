import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../app/theme.dart';
import '../models/car_model.dart';
import '../models/player_profile.dart';
import '../entities/player_car.dart';
import '../rendering/perspective_camera.dart';
import '../rendering/highway_3d_painter.dart';
import '../systems/traffic_system.dart';
import '../systems/collision_system.dart';
import '../systems/scoring_system.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';
import '../widgets/game_hud.dart';
import '../widgets/control_buttons.dart';
import 'pause_screen.dart';
import 'game_over_screen.dart';
import 'garage_screen.dart';

class GameplayScreen extends StatefulWidget {
  final PlayerProfile profile;
  final String gameMode; // 'endless', 'time_trial', 'traffic_challenge'
  final VoidCallback onExitToMenu;

  const GameplayScreen({
    super.key,
    required this.profile,
    this.gameMode = 'endless',
    required this.onExitToMenu,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ticker;
  late final PerspectiveCamera _camera;
  late PlayerCar _playerCar;
  late final TrafficSystem _trafficSystem;
  late final ScoringSystem _scoringSystem;

  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  double _lastTimestamp = 0.0;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isNewHighScore = false;
  double _nitroEffectIntensity = 0.0;
  double _crashTimer = 0.0;

  // Time Trial & Traffic Challenge specific trackers
  double _timeTrialSeconds = 60.0;
  static const int _trafficTargetOvertakes = 20;

  // Near miss combo floating alert
  String? _nearMissBanner;
  Timer? _nearMissBannerTimer;

  // Input states
  double _buttonSteer = 0.0;
  double _tiltSteer = 0.0;
  bool _isBraking = false;
  bool _isNitroRequested = false;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initGameSession();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 999),
    )..addListener(_gameLoop);

    _ticker.forward();

    _initSensors();
  }

  void _initGameSession() {
    final carModel = CarModel.allCars.firstWhere(
      (c) => c.id == widget.profile.selectedCarId,
      orElse: () => CarModel.allCars.first,
    );

    _playerCar = PlayerCar(model: carModel, profile: widget.profile);
    _camera = PerspectiveCamera();
    _trafficSystem = TrafficSystem();
    _scoringSystem = ScoringSystem();

    _playerCar.isAccelerating = true;
    _timeTrialSeconds = 60.0;
    _isPaused = false;
    _isGameOver = false;
    _isNewHighScore = false;
    _nitroEffectIntensity = 0.0;
    _crashTimer = 0.0;
    _buttonSteer = 0.0;
    _tiltSteer = 0.0;
    _isBraking = false;
    _isNitroRequested = false;
  }

  void _initSensors() {
    if (!widget.profile.useTiltControls) return;

    try {
      _accelerometerSub = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          if (!mounted || _isPaused || _isGameOver) return;
          // In landscape orientation, device tilt along Y axis indicates steering
          final double steerVal = (-event.y / 4.5).clamp(-1.0, 1.0);
          setState(() {
            _tiltSteer = (steerVal.abs() > 0.08) ? steerVal : 0.0;
          });
        },
        onError: (_) {
          // Accelerometer not present (e.g. desktop), fallback gracefully
        },
      );
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!_isPaused && !_isGameOver) {
        _pauseGame();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _accelerometerSub?.cancel();
    _nearMissBannerTimer?.cancel();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _gameLoop() {
    if (_isPaused || !mounted) return;

    final double now = _ticker.lastElapsedDuration?.inMicroseconds.toDouble() ?? 0.0;
    if (_lastTimestamp == 0.0) {
      _lastTimestamp = now;
      return;
    }

    double dt = (now - _lastTimestamp) / 1000000.0;
    _lastTimestamp = now;

    // Clamp delta time to avoid large physics steps on frame drops
    dt = dt.clamp(0.001, 0.05);

    _updateGamePhysics(dt);
  }

  void _updateGamePhysics(double dt) {
    // 1. Check crash delay state
    if (_playerCar.isCrashed) {
      _crashTimer += dt;
      _playerCar.update(dt);
      _camera.x += math.sin(_crashTimer * 40.0) * (3.0 * (1.2 - _crashTimer).clamp(0.0, 1.2));
      _nitroEffectIntensity = math.max(0.0, _nitroEffectIntensity - (4.0 * dt));

      if (_crashTimer >= 1.2 && !_isGameOver) {
        _triggerGameOver();
      }
      setState(() {});
      return;
    }

    // 2. Apply Inputs
    final double steer = widget.profile.useTiltControls ? _tiltSteer : _buttonSteer;
    _playerCar.steerInput = steer;
    _playerCar.isBraking = _isBraking;
    _playerCar.isAccelerating = true;

    // Nitro consumption
    if (_isNitroRequested && _playerCar.nitroLevel > 0.2) {
      _playerCar.isNitroActive = true;
    } else {
      _playerCar.isNitroActive = false;
    }

    // Nitro effect intensity interpolation
    final double targetNitro = _playerCar.isNitroActive ? 1.0 : 0.0;
    _nitroEffectIntensity += (targetNitro - _nitroEffectIntensity) * math.min(1.0, 10.0 * dt);

    // 3. Update Player Car
    _playerCar.update(dt);

    // 4. Update Camera Chase & FOV
    _camera.z = _playerCar.worldZ - 260.0;
    _camera.x += ((_playerCar.worldX * 0.45) - _camera.x) * math.min(1.0, 7.0 * dt);
    _camera.fovMultiplier = 1.0 + (_nitroEffectIntensity * 0.16);

    // 5. Update Traffic & Pickups
    _trafficSystem.update(dt, _playerCar.worldZ, _scoringSystem.distanceTravelled);

    // 6. Collision & Pickups Detection
    final CollisionResult result = CollisionSystem.checkCollisions(
      player: _playerCar,
      traffic: _trafficSystem.vehicles,
      pickups: _trafficSystem.pickups,
    );

    if (result.coinsCollected > 0) {
      for (int i = 0; i < result.coinsCollected; i++) {
        _scoringSystem.onCoinCollected();
      }
      AudioService.instance.playCoinPickup();
    }

    if (result.collectedNitro) {
      _playerCar.addNitro(3.5);
      AudioService.instance.playCoinPickup();
    }

    if (result.nearMiss) {
      _scoringSystem.onNearMiss();
      _showNearMissBanner('+100 x${_scoringSystem.comboMultiplier} NEAR MISS!');
    }

    if (result.hasCrashed) {
      _playerCar.isCrashed = true;
      AudioService.instance.playCollision();
      setState(() {});
      return;
    }

    // 7. Distance & Mode Progress
    _scoringSystem.updateDistance(_playerCar.worldZ / 10.0);

    // Count overtakes: player has passed vehicles that are behind
    for (final v in _trafficSystem.vehicles) {
      if (v.worldZ < _playerCar.worldZ && !v.hasBeenOvertaken) {
        v.hasBeenOvertaken = true;
        _scoringSystem.overtakesCount++;
      }
    }

    // Mode-specific goals
    if (widget.gameMode == 'time_trial') {
      _timeTrialSeconds -= dt;
      if (_timeTrialSeconds <= 0.0) {
        _timeTrialSeconds = 0.0;
        _triggerGameOver();
      }
    } else if (widget.gameMode == 'traffic_challenge') {
      if (_scoringSystem.overtakesCount >= _trafficTargetOvertakes && !_isGameOver) {
        _triggerGameOver(isVictory: true);
      }
    }

    setState(() {});
  }

  void _showNearMissBanner(String text) {
    _nearMissBannerTimer?.cancel();
    setState(() {
      _nearMissBanner = text;
    });
    _nearMissBannerTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _nearMissBanner = null;
        });
      }
    });
  }

  void _pauseGame() {
    AudioService.instance.playButtonClick();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeGame() {
    AudioService.instance.playButtonClick();
    setState(() {
      _isPaused = false;
      _lastTimestamp = 0.0;
    });
  }

  void _restartGame() {
    AudioService.instance.playButtonClick();
    setState(() {
      _initGameSession();
      _lastTimestamp = 0.0;
    });
  }

  void _triggerGameOver({bool isVictory = false}) {
    final finalScore = _scoringSystem.score + (isVictory ? 5000 : 0);
    _isNewHighScore = finalScore > widget.profile.highScore;

    if (_isNewHighScore) {
      widget.profile.highScore = finalScore;
    }

    widget.profile.coins += _scoringSystem.coinsThisRun;
    widget.profile.totalDistance += (_playerCar.worldZ / 10.0).toInt();

    SaveService.saveProfile(widget.profile);

    setState(() {
      _isGameOver = true;
    });
  }

  void _openGarage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GarageScreen(
          profile: widget.profile,
          onBack: () {
            Navigator.of(ctx).pop();
            _restartGame();
          },
        ),
      ),
    );
  }

  // Keyboard controls for macOS desktop & web testing
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
        _buttonSteer = -1.0;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
        _buttonSteer = 1.0;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
        _isBraking = true;
      } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.shiftLeft) {
        _isNitroRequested = true;
        AudioService.instance.playNitroBoost();
      } else if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.keyP) {
        if (!_isGameOver) {
          _isPaused ? _resumeGame() : _pauseGame();
        }
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _buttonSteer = 0.0;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
        _isBraking = false;
      } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.shiftLeft) {
        _isNitroRequested = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. 3D Highway Perspective Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: Highway3DPainter(
                  camera: _camera,
                  player: _playerCar,
                  traffic: _trafficSystem.vehicles,
                  pickups: _trafficSystem.pickups,
                  theme: widget.profile.currentTheme,
                  nitroEffectIntensity: _nitroEffectIntensity,
                ),
              ),
            ),

            // 2. Head-Up Display (HUD)
            Positioned.fill(
              child: GameHud(
                score: _scoringSystem.score,
                coins: _scoringSystem.coinsThisRun,
                distance: _scoringSystem.distanceTravelled,
                speed: _playerCar.speed,
                topSpeed: _playerCar.topSpeed,
                currentNitro: _playerCar.nitroLevel,
                maxNitro: _playerCar.nitroMax,
                isBoosting: _playerCar.isNitroActive,
                comboMultiplier: _scoringSystem.comboMultiplier,
                onPause: _pauseGame,
              ),
            ),

            // Mode indicator banner (Time trial countdown / Traffic goal)
            if (widget.gameMode == 'time_trial')
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_timeTrialSeconds <= 10.0 ? TurboTheme.neonRed : TurboTheme.neonCyan)
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _timeTrialSeconds <= 10.0 ? TurboTheme.neonRed : TurboTheme.neonCyan,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '⏱️ TIME LEFT: ${_timeTrialSeconds.toStringAsFixed(1)}s',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _timeTrialSeconds <= 10.0 ? TurboTheme.neonRed : TurboTheme.neonCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

            if (widget.gameMode == 'traffic_challenge')
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: TurboTheme.neonGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TurboTheme.neonGold, width: 1.5),
                    ),
                    child: Text(
                      '🎯 OVERTAKES: ${_scoringSystem.overtakesCount} / $_trafficTargetOvertakes',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: TurboTheme.neonGold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Near Miss Alert Popup
            if (_nearMissBanner != null)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: TurboTheme.neonPink.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: TurboTheme.neonPink, width: 2),
                        boxShadow: TurboTheme.pinkGlow(blur: 16),
                      ),
                      child: Text(
                        _nearMissBanner!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Mobile Controls (Touch Buttons)
            if (!widget.profile.useTiltControls && !_isPaused && !_isGameOver)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MobileControlButtons(
                  onSteer: (val) {
                    setState(() {
                      _buttonSteer = val;
                    });
                  },
                  onBrake: (val) {
                    setState(() {
                      _isBraking = val;
                    });
                  },
                  onNitro: (val) {
                    setState(() {
                      _isNitroRequested = val;
                    });
                    if (val) AudioService.instance.playNitroBoost();
                  },
                  isNitroActive: _playerCar.isNitroActive,
                  canUseNitro: _playerCar.nitroLevel > 0.5,
                ),
              ),

            // If tilt controls are on, show Brake and Nitro pedals only on bottom right
            if (widget.profile.useTiltControls && !_isPaused && !_isGameOver)
              Positioned(
                right: 20,
                bottom: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brake Pedal
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isBraking = true),
                      onTapUp: (_) => setState(() => _isBraking = false),
                      onTapCancel: () => setState(() => _isBraking = false),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TurboTheme.neonRed.withValues(alpha: 0.3),
                          border: Border.all(color: TurboTheme.neonRed, width: 2),
                        ),
                        child: const Icon(Icons.pan_tool_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nitro Boost
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() => _isNitroRequested = true);
                        AudioService.instance.playNitroBoost();
                      },
                      onTapUp: (_) => setState(() => _isNitroRequested = false),
                      onTapCancel: () => setState(() => _isNitroRequested = false),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_playerCar.isNitroActive ? TurboTheme.neonPink : TurboTheme.neonGold)
                              .withValues(alpha: 0.3),
                          border: Border.all(
                            color: _playerCar.isNitroActive ? TurboTheme.neonPink : TurboTheme.neonGold,
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                  ],
                ),
              ),

            // 5. Pause Screen Overlay
            if (_isPaused)
              Positioned.fill(
                child: PauseScreen(
                  onResume: _resumeGame,
                  onRestart: _restartGame,
                  onMainMenu: widget.onExitToMenu,
                ),
              ),

            // 6. Game Over Screen Overlay
            if (_isGameOver)
              Positioned.fill(
                child: GameOverScreen(
                  finalScore: _scoringSystem.score,
                  coinsEarned: _scoringSystem.coinsThisRun,
                  distance: _scoringSystem.distanceTravelled,
                  nearMisses: _scoringSystem.nearMissCount,
                  isNewHighScore: _isNewHighScore,
                  onRetry: _restartGame,
                  onGarage: _openGarage,
                  onMainMenu: widget.onExitToMenu,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
