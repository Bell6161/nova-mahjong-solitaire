import 'package:flutter/material.dart';
import '../../models/game_theme.dart';
import '../../models/mahjong_layout.dart';
import '../../services/storage_service.dart';

class StageSelectDialog extends StatelessWidget {
  final GameTheme theme;
  final int currentStageId;
  final Function(MahjongLayout layout) onSelectStage;

  const StageSelectDialog({
    super.key,
    required this.theme,
    required this.currentStageId,
    required this.onSelectStage,
  });

  @override
  Widget build(BuildContext context) {
    final stages = MahjongLayout.allStages();
    final int maxUnlocked = StorageService.getMaxUnlockedStage();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 540),
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
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_view_rounded, color: theme.tileHighlightColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'STAGE SELECTION',
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
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: stages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final stage = stages[index];
                  final bool isUnlocked = stage.id <= maxUnlocked;
                  final bool isCurrent = stage.id == currentStageId;
                  final int stars = StorageService.getStageStars(stage.id);

                  return InkWell(
                    onTap: isUnlocked
                        ? () {
                            Navigator.pop(context);
                            onSelectStage(stage);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? theme.tileHighlightColor.withOpacity(0.2)
                            : theme.boardBackgroundColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? theme.tileHighlightColor
                              : theme.gridLineColor.withOpacity(0.4),
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Stage Number Badge
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? theme.tileHighlightColor.withOpacity(0.25)
                                  : Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isUnlocked
                                  ? Text(
                                      '${stage.id}',
                                      style: TextStyle(
                                        color: theme.primaryTextColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    )
                                  : const Icon(Icons.lock_rounded, size: 18, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Stage Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.name,
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? theme.primaryTextColor
                                        : theme.primaryTextColor.withOpacity(0.4),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stage.difficulty} • ${stage.tileCount} Tiles',
                                  style: TextStyle(
                                    color: theme.secondaryTextColor.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Stars earned
                          if (isUnlocked)
                            Row(
                              children: List.generate(3, (starIdx) {
                                return Icon(
                                  starIdx < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 20,
                                  color: starIdx < stars ? const Color(0xFFFFD700) : Colors.grey,
                                );
                              }),
                            ),
                        ],
                      ),
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
