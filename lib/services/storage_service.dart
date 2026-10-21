import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keySound = 'mahjong_sound_enabled';
  static const String _keyHaptics = 'mahjong_haptics_enabled';
  static const String _keyTheme = 'mahjong_selected_theme';
  static const String _keyUserName = 'mahjong_user_name';
  static const String _keyAvatarPath = 'mahjong_custom_avatar_path';
  static const String _keyAvatarId = 'mahjong_avatar_id';
  static const String _keyHints = 'mahjong_hints_count';
  static const String _keyShuffles = 'mahjong_shuffles_count';
  static const String _keyUndos = 'mahjong_undos_count';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- High Scores (Deduplicated Single-Best Per Mode) ---
  static int getHighScore(String modeKey) {
    return _prefs?.getInt('highscore_$modeKey') ?? 0;
  }

  /// Returns true if this is a new personal best score
  static Future<bool> saveHighScore(String modeKey, int score) async {
    final currentBest = getHighScore(modeKey);
    if (score > currentBest) {
      await _prefs?.setInt('highscore_$modeKey', score);
      return true;
    }
    return false;
  }

  // --- Stage Progress & Stars ---
  static int getStageStars(int stageId) {
    return _prefs?.getInt('stage_stars_$stageId') ?? 0;
  }

  static Future<void> saveStageStars(int stageId, int stars) async {
    final current = getStageStars(stageId);
    if (stars > current) {
      await _prefs?.setInt('stage_stars_$stageId', stars);
    }
  }

  static int getMaxUnlockedStage() {
    return _prefs?.getInt('max_unlocked_stage') ?? 1;
  }

  static Future<void> unlockNextStage(int completedStageId) async {
    final maxCurrent = getMaxUnlockedStage();
    if (completedStageId >= maxCurrent) {
      await _prefs?.setInt('max_unlocked_stage', completedStageId + 1);
    }
  }

  // --- Settings ---
  static bool get soundEnabled => _prefs?.getBool(_keySound) ?? true;
  static Future<void> setSoundEnabled(bool value) async =>
      await _prefs?.setBool(_keySound, value);

  static bool get hapticsEnabled => _prefs?.getBool(_keyHaptics) ?? true;
  static Future<void> setHapticsEnabled(bool value) async =>
      await _prefs?.setBool(_keyHaptics, value);

  static String get selectedTheme => _prefs?.getString(_keyTheme) ?? 'traditional';
  static Future<void> setSelectedTheme(String themeKey) async =>
      await _prefs?.setString(_keyTheme, themeKey);

  // --- Profile ---
  static String get userName => _prefs?.getString(_keyUserName) ?? 'ZenMaster';
  static Future<void> setUserName(String name) async =>
      await _prefs?.setString(_keyUserName, name);

  static String? get customAvatarPath => _prefs?.getString(_keyAvatarPath);
  static Future<void> setCustomAvatarPath(String? path) async {
    if (path == null) {
      await _prefs?.remove(_keyAvatarPath);
    } else {
      await _prefs?.setString(_keyAvatarPath, path);
    }
  }

  static int get avatarId => _prefs?.getInt(_keyAvatarId) ?? 0;
  static Future<void> setAvatarId(int id) async =>
      await _prefs?.setInt(_keyAvatarId, id);

  // --- Boosters Inventory ---
  static int get hintCount => _prefs?.getInt(_keyHints) ?? 5;
  static Future<void> setHintCount(int count) async =>
      await _prefs?.setInt(_keyHints, count);

  static int get shuffleCount => _prefs?.getInt(_keyShuffles) ?? 3;
  static Future<void> setShuffleCount(int count) async =>
      await _prefs?.setInt(_keyShuffles, count);

  static int get undoCount => _prefs?.getInt(_keyUndos) ?? 5;
  static Future<void> setUndoCount(int count) async =>
      await _prefs?.setInt(_keyUndos, count);
}
