import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _matchPlayer = AudioPlayer();
  static final AudioPlayer _ambientPlayer = AudioPlayer();

  static Future<void> init() async {
    try {
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _matchPlayer.setPlayerMode(PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('AudioService init note: $e');
    }
  }

  static Future<void> playTileClick() async {
    if (!StorageService.soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/tile_click.wav'));
    } catch (e) {
      debugPrint('Audio click error: $e');
    }
  }

  static Future<void> playTileMatch({int combo = 1}) async {
    if (!StorageService.soundEnabled) return;
    try {
      await _matchPlayer.stop();
      // For higher combos, slightly increase playback rate or pitch if supported
      if (combo > 1) {
        await _matchPlayer.setPlaybackRate(1.0 + (combo * 0.05).clamp(0.0, 0.5));
      } else {
        await _matchPlayer.setPlaybackRate(1.0);
      }
      await _matchPlayer.play(AssetSource('audio/tile_match.wav'));
    } catch (e) {
      debugPrint('Audio match error: $e');
    }
  }

  static Future<void> playTileDeselect() async {
    if (!StorageService.soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/tile_deselect.wav'));
    } catch (e) {
      debugPrint('Audio deselect error: $e');
    }
  }

  static Future<void> playHint() async {
    if (!StorageService.soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/hint.wav'));
    } catch (e) {
      debugPrint('Audio hint error: $e');
    }
  }

  static Future<void> playShuffle() async {
    if (!StorageService.soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/shuffle.wav'));
    } catch (e) {
      debugPrint('Audio shuffle error: $e');
    }
  }

  static Future<void> playVictory() async {
    if (!StorageService.soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/victory.wav'));
    } catch (e) {
      debugPrint('Audio victory error: $e');
    }
  }

  static void dispose() {
    _sfxPlayer.dispose();
    _matchPlayer.dispose();
    _ambientPlayer.dispose();
  }
}
