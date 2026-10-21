import 'package:flutter/material.dart';
import '../../models/game_theme.dart';
import '../../models/game_mode.dart';
import '../../services/storage_service.dart';
import 'leaderboard_dialog.dart';
import 'profile_dialog.dart';

class SettingsDialog extends StatefulWidget {
  final GameTheme theme;
  final GameMode currentMode;
  final Function(GameMode mode) onModeChanged;
  final VoidCallback onSettingsUpdated;

  const SettingsDialog({
    super.key,
    required this.theme,
    required this.currentMode,
    required this.onModeChanged,
    required this.onSettingsUpdated,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _sound;
  late bool _haptics;
  late GameModeType _selectedMode;

  @override
  void initState() {
    super.initState();
    _sound = StorageService.soundEnabled;
    _haptics = StorageService.hapticsEnabled;
    _selectedMode = widget.currentMode.type;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: widget.theme.cardBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: widget.theme.tileHighlightColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, color: widget.theme.tileHighlightColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'SETTINGS & MODES',
                        style: TextStyle(
                          color: widget.theme.primaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.theme.primaryTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hall of Fame & Profile quick shortcuts
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => LeaderboardDialog(theme: widget.theme),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 18),
                      label: Text(
                        'Hall of Fame',
                        style: TextStyle(color: widget.theme.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: widget.theme.gridLineColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(
                            theme: widget.theme,
                            onProfileUpdated: widget.onSettingsUpdated,
                          ),
                        );
                      },
                      icon: Icon(Icons.account_circle_rounded, color: widget.theme.secondaryTextColor, size: 18),
                      label: Text(
                        'Profile',
                        style: TextStyle(color: widget.theme.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: widget.theme.gridLineColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Game Mode selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.theme.boardBackgroundColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.theme.gridLineColor.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAME MODE',
                      style: TextStyle(
                        color: widget.theme.secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildModeRadio(
                      title: 'Classic Stages',
                      subtitle: 'Progressive levels with timer & star ratings',
                      type: GameModeType.classic,
                    ),
                    _buildModeRadio(
                      title: 'Zen Relax (Untimed)',
                      subtitle: 'Mindful untimed play with ambient comfort',
                      type: GameModeType.zenRelax,
                    ),
                    _buildModeRadio(
                      title: 'Daily Challenge',
                      subtitle: 'Global daily seed with leaderboard rating',
                      type: GameModeType.daily,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Audio & Haptics Toggles
              SwitchListTile(
                title: Text('Sound Effects (SFX)', style: TextStyle(color: widget.theme.primaryTextColor, fontWeight: FontWeight.bold)),
                subtitle: Text('Authentic acoustic tile clicks & matches', style: TextStyle(color: widget.theme.secondaryTextColor, fontSize: 12)),
                value: _sound,
                activeColor: widget.theme.tileHighlightColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) async {
                  setState(() => _sound = val);
                  await StorageService.setSoundEnabled(val);
                  widget.onSettingsUpdated();
                },
              ),
              SwitchListTile(
                title: Text('Haptic Vibration', style: TextStyle(color: widget.theme.primaryTextColor, fontWeight: FontWeight.bold)),
                subtitle: Text('Tactile response on taps and combos', style: TextStyle(color: widget.theme.secondaryTextColor, fontSize: 12)),
                value: _haptics,
                activeColor: widget.theme.tileHighlightColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) async {
                  setState(() => _haptics = val);
                  await StorageService.setHapticsEnabled(val);
                  widget.onSettingsUpdated();
                },
              ),

              const SizedBox(height: 10),

              // Rules Helper
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.theme.boardBackgroundColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOW TO PLAY',
                      style: TextStyle(color: widget.theme.tileHighlightColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Match 2 identical, unblocked tiles to clear them.\n'
                      '• A tile is free if no tile covers it from above AND at least one lateral side (left or right) is open.\n'
                      '• Match quickly to build combos for higher scores!',
                      style: TextStyle(color: widget.theme.primaryTextColor.withOpacity(0.8), fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeRadio({
    required String title,
    required String subtitle,
    required GameModeType type,
  }) {
    final bool isSelected = _selectedMode == type;
    return InkWell(
      onTap: () {
        setState(() => _selectedMode = type);
        GameMode chosen;
        switch (type) {
          case GameModeType.zenRelax:
            chosen = GameMode.zenRelax;
            break;
          case GameModeType.daily:
            chosen = GameMode.daily;
            break;
          case GameModeType.classic:
          default:
            chosen = GameMode.classic;
            break;
        }
        widget.onModeChanged(chosen);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? widget.theme.tileHighlightColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: widget.theme.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: widget.theme.secondaryTextColor.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
