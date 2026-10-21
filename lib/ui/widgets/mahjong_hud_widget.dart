import 'package:flutter/material.dart';
import '../../models/game_theme.dart';
import '../../models/game_mode.dart';

class MahjongHudWidget extends StatelessWidget {
  final GameTheme theme;
  final GameMode mode;
  final String stageName;
  final int score;
  final int remainingPairs;
  final int availableMoves;
  final int elapsedSeconds;
  final int hintCount;
  final int shuffleCount;
  final int undoCount;
  final VoidCallback onHint;
  final VoidCallback onShuffle;
  final VoidCallback onUndo;
  final VoidCallback onMenu;
  final VoidCallback onSettings;
  final VoidCallback onStages;

  const MahjongHudWidget({
    super.key,
    required this.theme,
    required this.mode,
    required this.stageName,
    required this.score,
    required this.remainingPairs,
    required this.availableMoves,
    required this.elapsedSeconds,
    required this.hintCount,
    required this.shuffleCount,
    required this.undoCount,
    required this.onHint,
    required this.onShuffle,
    required this.onUndo,
    required this.onMenu,
    required this.onSettings,
    required this.onStages,
  });

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- TOP APP BAR & STATUS ---
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stage selector button
                    _buildIconButton(
                      icon: Icons.grid_view_rounded,
                      tooltip: 'Select Stage',
                      onPressed: onStages,
                    ),

                    // Stage Name & Timer
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            stageName,
                            style: TextStyle(
                              color: theme.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mode.hasTimer ? Icons.timer_outlined : Icons.all_inclusive,
                                size: 14,
                                color: theme.secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mode.hasTimer ? _formatTime(elapsedSeconds) : 'ZEN UNTIMED',
                                style: TextStyle(
                                  color: theme.secondaryTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Settings & Themes
                    Row(
                      children: [
                        _buildIconButton(
                          icon: Icons.palette_outlined,
                          tooltip: 'Themes',
                          onPressed: onMenu,
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          icon: Icons.settings_outlined,
                          tooltip: 'Settings',
                          onPressed: onSettings,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Stat Badges (Score & Remaining Pairs & Available Moves)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatPill(
                      label: 'SCORE',
                      value: '$score',
                      color: theme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    _buildStatPill(
                      label: 'PAIRS',
                      value: '$remainingPairs',
                      color: const Color(0xFF64B5F6),
                    ),
                    const SizedBox(width: 8),
                    _buildStatPill(
                      label: 'MOVES',
                      value: '$availableMoves',
                      color: availableMoves > 0 ? const Color(0xFF81C784) : const Color(0xFFE57373),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // --- BOTTOM BOOSTER DOCK ---
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBoosterButton(
                  icon: Icons.lightbulb_rounded,
                  label: 'Hint',
                  count: hintCount,
                  accentColor: const Color(0xFFFFB300),
                  onPressed: onHint,
                ),
                _buildBoosterButton(
                  icon: Icons.shuffle_rounded,
                  label: 'Shuffle',
                  count: shuffleCount,
                  accentColor: const Color(0xFF42A5F5),
                  onPressed: onShuffle,
                ),
                _buildBoosterButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  count: undoCount,
                  accentColor: const Color(0xFFAB47BC),
                  onPressed: onUndo,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor.withOpacity(0.85),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.primaryTextColor, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: theme.primaryTextColor.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterButton({
    required IconData icon,
    required String label,
    required int count,
    required Color accentColor,
    required VoidCallback onPressed,
  }) {
    final bool isEnabled = count > 0;
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 84,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? theme.cardBackgroundColor.withOpacity(0.92)
                  : theme.cardBackgroundColor.withOpacity(0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isEnabled ? accentColor.withOpacity(0.7) : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEnabled ? accentColor.withOpacity(0.25) : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? accentColor : Colors.grey,
                  size: 26,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? theme.primaryTextColor : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Badge indicator
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
