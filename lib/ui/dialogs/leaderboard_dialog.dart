import 'package:flutter/material.dart';
import '../../models/game_theme.dart';
import '../../services/storage_service.dart';

class LeaderboardDialog extends StatelessWidget {
  final GameTheme theme;

  const LeaderboardDialog({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final playerName = StorageService.userName;
    final int userBestClassic = StorageService.getHighScore('classic');
    final int userBestZen = StorageService.getHighScore('zenRelax');
    final int userBestDaily = StorageService.getHighScore('daily');

    // Hall of Fame masters with user's deduplicated single personal best integrated
    final List<Map<String, dynamic>> masters = [
      {'name': 'Master Shen', 'score': 18450, 'avatar': '🐉'},
      {'name': 'Lady Lin', 'score': 15200, 'avatar': '🌸'},
      {'name': playerName, 'score': userBestClassic, 'isUser': true, 'avatar': '👑'},
      {'name': 'Elder Wu', 'score': 12100, 'avatar': '🎋'},
      {'name': 'Monk Tao', 'score': 9800, 'avatar': '☯️'},
    ]..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor.withOpacity(0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.tileHighlightColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 26),
                    const SizedBox(width: 8),
                    Text(
                      'HALL OF FAME',
                      style: TextStyle(
                        color: theme.primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.primaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // User Single Best Record Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.tileHighlightColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.tileHighlightColor, width: 1.5),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFFD700),
                    child: Text('👑', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$playerName (Your Personal Best)',
                          style: TextStyle(
                            color: theme.primaryTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Classic: $userBestClassic pts • Zen: $userBestZen pts • Daily: $userBestDaily pts',
                          style: TextStyle(
                            color: theme.secondaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Ranking list
            Expanded(
              child: ListView.separated(
                itemCount: masters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = masters[index];
                  final bool isUser = entry['isUser'] == true;
                  final int rank = index + 1;

                  Color rankColor = theme.secondaryTextColor;
                  if (rank == 1) rankColor = const Color(0xFFFFD700);
                  if (rank == 2) rankColor = const Color(0xFFE0E0E0);
                  if (rank == 3) rankColor = const Color(0xFFCD7F32);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.tileHighlightColor.withOpacity(0.2)
                          : theme.boardBackgroundColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUser ? theme.tileHighlightColor : theme.gridLineColor.withOpacity(0.3),
                        width: isUser ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          entry['avatar'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry['name'] as String,
                            style: TextStyle(
                              color: theme.primaryTextColor,
                              fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${entry['score']} pts',
                          style: TextStyle(
                            color: isUser ? theme.tileHighlightColor : theme.secondaryTextColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
