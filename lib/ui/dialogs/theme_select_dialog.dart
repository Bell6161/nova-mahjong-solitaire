import 'package:flutter/material.dart';
import '../../models/game_theme.dart';
import '../../services/storage_service.dart';
import '../../services/sprite_manager.dart';

class ThemeSelectDialog extends StatelessWidget {
  final GameTheme currentTheme;
  final Function(GameTheme theme) onThemeSelected;

  const ThemeSelectDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: currentTheme.cardBackgroundColor.withOpacity(0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: currentTheme.tileHighlightColor.withOpacity(0.5), width: 1.5),
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
                    Icon(Icons.palette_rounded, color: currentTheme.tileHighlightColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'VISUAL THEMES',
                      style: TextStyle(
                        color: currentTheme.primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: currentTheme.primaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Theme Cards
            ...GameTheme.themes.map((theme) {
              final bool isSelected = theme.type == currentTheme.type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    await StorageService.setSelectedTheme(theme.tileFolder);
                    await SpriteManager.preloadTheme(theme.tileFolder);
                    onThemeSelected(theme);
                    if (context.mounted) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.boardBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.tileHighlightColor : theme.gridLineColor,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.tileHighlightColor.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Preview circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.tileHighlightColor, width: 2),
                            gradient: LinearGradient(
                              colors: [theme.backgroundColor, theme.cardBackgroundColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.auto_awesome,
                              size: 20,
                              color: theme.tileHighlightColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theme.name,
                                style: TextStyle(
                                  color: theme.primaryTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                theme.subtitle,
                                style: TextStyle(
                                  color: theme.secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: theme.tileHighlightColor, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
