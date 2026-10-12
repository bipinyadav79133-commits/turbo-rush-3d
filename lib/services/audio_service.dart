import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool soundEnabled = true;
  bool musicEnabled = true;

  void init({required bool sound, required bool music}) {
    soundEnabled = sound;
    musicEnabled = music;
  }

  void playButtonClick() {
    if (!soundEnabled) return;
    HapticFeedback.lightImpact();
  }

  void playCoinPickup() {
    if (!soundEnabled) return;
    HapticFeedback.selectionClick();
  }

  void playNitroBoost() {
    if (!soundEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void playCollision() {
    if (!soundEnabled) return;
    HapticFeedback.vibrate();
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}
