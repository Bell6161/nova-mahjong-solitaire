import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/mahjong_tile.dart';
import '../../models/mahjong_layout.dart';
import '../../models/game_theme.dart';
import '../../models/game_mode.dart';
import '../../logic/mahjong_engine.dart';
import '../../services/audio_service.dart';
import '../../services/storage_service.dart';
import '../../services/sprite_manager.dart';
import '../widgets/mahjong_board_widget.dart';
import '../widgets/mahjong_hud_widget.dart';
import '../widgets/zen_vfx_overlay.dart';
import '../dialogs/stage_select_dialog.dart';
import '../dialogs/theme_select_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MahjongEngine _engine;
  late MahjongLayout _currentLayout;
  late GameTheme _currentTheme;
  GameMode _currentMode = GameMode.classic;

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  final ZenVfxController _vfxController = ZenVfxController();

  Offset? _firstTileTapGlobalPos;

  @override
  void initState() {
    super.initState();
    _currentLayout = MahjongLayout.pagoda();
    _engine = MahjongEngine(layout: _currentLayout);

    // Load saved theme
    final savedThemeKey = StorageService.selectedTheme;
    _currentTheme = GameTheme.themes.firstWhere(
      (t) => t.tileFolder == savedThemeKey,
      orElse: () => GameTheme.traditional,
    );

    _loadAssetsAndStart();
  }

  void _loadAssetsAndStart() async {
    await SpriteManager.preloadTheme(_currentTheme.tileFolder);
    if (mounted) {
      setState(() {});
    }
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused && mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vfxController.dispose();
    super.dispose();
  }

  void _onTileTapped(MahjongTile tile, Offset globalCenter) {
    if (_isPaused) return;

    if (tile.isRemoved) return;
    if (!_engine.isTileFree(tile)) {
      if (StorageService.hapticsEnabled) {
        HapticFeedback.vibrate();
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tile is blocked! Unblock top or left/right sides first.'),
          duration: Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_engine.selectedTile == null) {
      _firstTileTapGlobalPos = globalCenter;
    }

    final res = _engine.tapTile(
      tile,
      onMatch: (action) {
        if (StorageService.hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        AudioService.playTileMatch(combo: action.combo);

        // Spawn gentle sparkle and score VFX
        final pos1 = _firstTileTapGlobalPos ?? globalCenter;
        final pos2 = globalCenter;
        _vfxController.spawnMatchVfx(
          pos1: pos1,
          pos2: pos2,
          points: action.pointsEarned,
          combo: action.combo,
          accentColor: _currentTheme.tileHighlightColor,
        );

        // Check Victory
        if (_engine.isVictory) {
          _handleVictory();
        }
      },
    );

    if (res == 'selected') {
      _firstTileTapGlobalPos = globalCenter;
      if (StorageService.hapticsEnabled) HapticFeedback.selectionClick();
      AudioService.playTileClick();
    } else if (res == 'deselected') {
      _firstTileTapGlobalPos = null;
      AudioService.playTileDeselect();
    } else if (res == 'mismatch') {
      _firstTileTapGlobalPos = globalCenter;
      if (StorageService.hapticsEnabled) HapticFeedback.selectionClick();
      AudioService.playTileClick();
    }

    setState(() {});
  }

  void _handleVictory() async {
    _timer?.cancel();
    AudioService.playVictory();

    // Calculate stars: 3 if speed clear (< 90s for lotus, < 180s for turtle)
    int stars = 1;
    if (_elapsedSeconds < 120) {
      stars = 3;
    } else if (_elapsedSeconds < 240) {
      stars = 2;
    }

    await StorageService.saveStageStars(_currentLayout.id, stars);
    await StorageService.unlockNextStage(_currentLayout.id);

    final modeKey = _currentMode.type == GameModeType.classic
        ? 'classic'
        : (_currentMode.type == GameModeType.zenRelax ? 'zenRelax' : 'daily');
    final isNewBest = await StorageService.saveHighScore(modeKey, _engine.score);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VictoryDialog(
        theme: _currentTheme,
        stageId: _currentLayout.id,
        stageName: _currentLayout.name,
        score: _engine.score,
        seconds: _elapsedSeconds,
        stars: stars,
        isNewBest: isNewBest,
        onReplay: () {
          setState(() {
            _engine.startNewGame();
            _startTimer();
          });
        },
        onNextStage: () {
          final all = MahjongLayout.allStages();
          final nextIdx = all.indexWhere((s) => s.id == _currentLayout.id) + 1;
          if (nextIdx < all.length) {
            _loadLayout(all[nextIdx]);
          } else {
            _loadLayout(all[0]);
          }
        },
      ),
    );
  }

  void _loadLayout(MahjongLayout layout) {
    setState(() {
      _currentLayout = layout;
      _engine = MahjongEngine(layout: _currentLayout);
      _vfxController.clear();
      _startTimer();
    });
  }

  // --- Boosters ---
  void _useHint() {
    final count = StorageService.hintCount;
    if (count <= 0) {
      _showBoosterDepletedSnack('No Hints left!');
      return;
    }

    final hint = _engine.getHint();
    if (hint != null) {
      StorageService.setHintCount(count - 1);
      AudioService.playHint();
      if (StorageService.hapticsEnabled) HapticFeedback.mediumImpact();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No legal moves currently open! Use Shuffle 🔀'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _useShuffle() {
    final count = StorageService.shuffleCount;
    if (count <= 0) {
      _showBoosterDepletedSnack('No Shuffles left!');
      return;
    }

    final success = _engine.shuffleRemainingTiles();
    if (success) {
      StorageService.setShuffleCount(count - 1);
      AudioService.playShuffle();
      if (StorageService.hapticsEnabled) HapticFeedback.mediumImpact();
      setState(() {});
    }
  }

  void _useUndo() {
    final count = StorageService.undoCount;
    if (count <= 0) {
      _showBoosterDepletedSnack('No Undos left!');
      return;
    }

    final success = _engine.undoLastMove();
    if (success) {
      StorageService.setUndoCount(count - 1);
      AudioService.playTileDeselect();
      if (StorageService.hapticsEnabled) HapticFeedback.lightImpact();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to undo!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBoosterDepletedSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Dialogs ---
  void _openStageSelect() async {
    setState(() => _isPaused = true);
    await showDialog(
      context: context,
      builder: (_) => StageSelectDialog(
        theme: _currentTheme,
        currentStageId: _currentLayout.id,
        onSelectStage: (layout) => _loadLayout(layout),
      ),
    );
    if (mounted) setState(() => _isPaused = false);
  }

  void _openThemeSelect() async {
    setState(() => _isPaused = true);
    await showDialog(
      context: context,
      builder: (_) => ThemeSelectDialog(
        currentTheme: _currentTheme,
        onThemeSelected: (theme) async {
          await SpriteManager.preloadTheme(theme.tileFolder);
          if (mounted) {
            setState(() {
              _currentTheme = theme;
            });
          }
        },
      ),
    );
    if (mounted) setState(() => _isPaused = false);
  }

  void _openSettings() async {
    setState(() => _isPaused = true);
    await showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        theme: _currentTheme,
        currentMode: _currentMode,
        onModeChanged: (mode) {
          setState(() {
            _currentMode = mode;
          });
        },
        onSettingsUpdated: () {
          setState(() {});
        },
      ),
    );
    if (mounted) setState(() => _isPaused = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: ZenVfxOverlay(
        controller: _vfxController,
        child: Stack(
          children: [
            // Ambient subtle background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      _currentTheme.boardBackgroundColor.withOpacity(0.4),
                      _currentTheme.backgroundColor,
                    ],
                  ),
                ),
              ),
            ),

            // Mahjong Interactive 3D Board (Screen-filling giant tiles)
            Positioned.fill(
              top: 110,
              bottom: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: MahjongBoardWidget(
                  engine: _engine,
                  theme: _currentTheme,
                  onTileTapped: _onTileTapped,
                ),
              ),
            ),

            // Top HUD & Bottom Booster Controls
            Positioned.fill(
              child: MahjongHudWidget(
                theme: _currentTheme,
                mode: _currentMode,
                stageName: _currentLayout.name,
                score: _engine.score,
                remainingPairs: _engine.remainingPairs,
                availableMoves: _engine.availableMovesCount,
                elapsedSeconds: _elapsedSeconds,
                hintCount: StorageService.hintCount,
                shuffleCount: StorageService.shuffleCount,
                undoCount: StorageService.undoCount,
                onHint: _useHint,
                onShuffle: _useShuffle,
                onUndo: _useUndo,
                onMenu: _openThemeSelect,
                onSettings: _openSettings,
                onStages: _openStageSelect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
