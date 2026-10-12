# 🏎️ Turbo Rush 3D

A high-octane 3D endless highway car racing game built with **Flutter & Dart**. Drive sports cars at breakneck speeds, weave through dynamic highway traffic, trigger nitro boosts, collect coins, and upgrade your vehicle lineup!

![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20macOS%20%7C%20Web-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🎮 Gameplay Features

- **🚀 Hardware-Accelerated 3D Perspective Engine**: Custom true 3D-to-2D vanishing-point projection delivering silky-smooth 60 FPS on mobile and desktop without black screens or heavy external C++ engine dependencies.
- **🏎️ 5 Distinct High-Performance Sports Cars**:
  - `Apex Cruiser` (Starter balanced sports coupe)
  - `Venom GT` (High-revving street racer)
  - `Phantom V8` (Raw American muscle beast)
  - `Vortex R` (Track-tuned aerodynamic supercar)
  - `Hyperion Evo` (Premium futuristic hypercar)
- **🔧 Deep Garage & Upgrade System**:
  - Engine Tuning (Top speed increase)
  - Twin Turbocharger (Acceleration boost)
  - Steering & Suspension (Handling & drift control)
  - Ceramic Brakes (Rapid deceleration)
  - Nitro Booster (Extended boost tank capacity)
- **🎯 3 Exciting Game Modes**:
  - **Endless Highway**: Survive as long as possible without crashing, racking up distance and near-miss points.
  - **Time Trial**: Race against a 60-second countdown clock.
  - **Traffic Challenge**: Objective-based race to overtake 20 highway vehicles.
- **💨 Adrenaline Systems**:
  - **Nitro Boost**: Warping camera FOV, speed tunnel vision lines, and instant surge to 250+ km/h.
  - **High-Speed Near Misses**: Overtake cars with tight clearance to stack up score multipliers (x2, x3, x5).
  - **Pickups**: In-run gold coins and nitro fuel canisters floating on road lanes.
- **🕹️ Dual Control Schemes**:
  - **Touch Controls**: On-screen buttons (Steer Left, Steer Right, Brake, Nitro Boost).
  - **Tilt / Gyro Steering**: Steer naturally by tilting the phone horizontally using accelerometer sensors.
  - **Keyboard Support**: Full desktop/web controls (Arrow Keys / A, D, S, Space, Shift, Esc).
- **💾 Local Data Persistence**: High scores, earned coins, unlocked cars, and tuning levels automatically persist via local storage.

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── app.dart              # MaterialApp root & dark neon cyberpunk theme
│   └── theme.dart            # Palette, neon accents, and glow effects
├── entities/
│   ├── player_car.dart       # 3D player vehicle with physics, tilt banking & nitro
│   ├── traffic_vehicle.dart  # 5 traffic vehicle archetypes (Sedan, Sports, SUV, Van, Truck)
│   └── coin_pickup.dart      # 3D rotating coins & nitro fuel canisters
├── models/
│   ├── car_model.dart        # Vehicle base stats, prices & colors
│   ├── upgrade_model.dart    # Tuning upgrade levels & costs
│   └── player_profile.dart   # Persistent player progression data
├── rendering/
│   ├── perspective_camera.dart # True 3D world-to-screen perspective camera
│   ├── road_segment.dart     # Road segment geometry, streetlights & billboards
│   └── highway_3d_painter.dart # CustomPainter rendering highway, scenery, cars & speed lines
├── screens/
│   ├── main_menu_screen.dart # Interactive garage showcase, modes & race launcher
│   ├── gameplay_screen.dart  # 60 FPS animation loop, HUD, input & camera follow
│   ├── garage_screen.dart    # 3D car carousel, upgrade shop & unlock system
│   ├── settings_screen.dart  # Audio toggles, tilt vs touch, & environment themes
│   ├── pause_screen.dart     # Pause overlay
│   └── game_over_screen.dart # Game Over summary, stats & high score notifications
├── services/
│   ├── save_service.dart     # Robust SharedPreferences data persistence
│   └── audio_service.dart    # Sound effects & haptic feedback controller
├── systems/
│   ├── traffic_system.dart   # Procedural traffic wave & pickup spawner
│   ├── collision_system.dart # 3D AABB bounding box collision & near-miss detection
│   └── scoring_system.dart   # Distance scoring & combo multiplier system
└── widgets/
    ├── control_buttons.dart  # Touch buttons for mobile driving
    ├── game_hud.dart         # Digital speedometer, nitro meter, score & combo
    ├── nitro_meter.dart      # Pulsing nitro gauge widget
    └── speedometer.dart      # Futuristic digital speedometer gauge
```

---

## 🚀 How to Run

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24+ recommended)
- Java 17+ / Android Studio (for Android build)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Desktop (macOS / Windows / Linux)
```bash
flutter run -d macos
```

### 3. Run on Web
```bash
flutter run -d chrome
```

### 4. Build Android APK
```bash
flutter build apk --release
```
The compiled APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## ⌨️ Desktop & Web Controls

| Action | Keyboard Key | Mobile Control |
|---|---|---|
| **Steer Left** | `←` or `A` | Left Arrow Button / Tilt Left |
| **Steer Right** | `→` or `D` | Right Arrow Button / Tilt Right |
| **Brake** | `↓` or `S` | Brake Pedal Button |
| **Nitro Boost** | `Space` or `Shift` | Nitro Button |
| **Pause Game** | `Esc` or `P` | Pause Button on HUD |

---

## 📄 License
MIT License. Open source and free to use!
