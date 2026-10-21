import 'package:flutter/material.dart';
import '../../models/game_theme.dart';

class VictoryDialog extends StatelessWidget {
  final GameTheme theme;
  final int stageId;
  final String stageName;
  final int score;
  final int seconds;
  final int stars;
  final bool isNewBest;
  final VoidCallback onNextStage;
  final VoidCallback onReplay;

  const VictoryDialog({
    super.key,
    required this.theme,
    required this.stageId,
    required this.stageName,
    required this.score,
    required this.seconds,
    required this.stars,
    required this.isNewBest,
    required this.onNextStage,
    required this.onReplay,
  });

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Crown
            const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 58),
            const SizedBox(height: 8),

            Text(
              'VICTORY!',
              style: TextStyle(
                color: theme.primaryTextColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            Text(
              stageName,
              style: TextStyle(
                color: theme.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    active ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 40,
                    color: active ? const Color(0xFFFFD700) : Colors.grey.withOpacity(0.5),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Score card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.boardBackgroundColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.gridLineColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'FINAL SCORE',
                        style: TextStyle(
                          color: theme.primaryTextColor.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (isNewBest)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NEW BEST!',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: theme.gridLineColor),
                  Column(
                    children: [
                      Text(
                        'CLEAR TIME',
                        style: TextStyle(
                          color: theme.primaryTextColor.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(seconds),
                        style: TextStyle(
                          color: theme.primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onReplay();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryTextColor,
                      side: BorderSide(color: theme.gridLineColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('REPLAY', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onNextStage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('NEXT STAGE', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
