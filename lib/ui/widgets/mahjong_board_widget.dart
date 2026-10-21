import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/mahjong_tile.dart';
import '../../models/game_theme.dart';
import '../../logic/mahjong_engine.dart';
import '../../services/sprite_manager.dart';

class MahjongBoardWidget extends StatefulWidget {
  final MahjongEngine engine;
  final GameTheme theme;
  final Function(MahjongTile tile, Offset globalCenter) onTileTapped;

  const MahjongBoardWidget({
    super.key,
    required this.engine,
    required this.theme,
    required this.onTileTapped,
  });

  @override
  State<MahjongBoardWidget> createState() => _MahjongBoardWidgetState();
}

class _MahjongBoardWidgetState extends State<MahjongBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final GlobalKey _paintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate board bounds from layout
        double minX = 999, maxX = -999, minY = 999, maxY = -999;
        for (final slot in widget.engine.layout.slots) {
          if (slot.x < minX) minX = slot.x;
          if (slot.x > maxX) maxX = slot.x;
          if (slot.y < minY) minY = slot.y;
          if (slot.y > maxY) maxY = slot.y;
        }

        // Add 1.0 unit margin for tile dimensions
        final double gridWidth = (maxX - minX + 1.6);
        final double gridHeight = (maxY - minY + 1.8);

        // Aspect ratio of Mahjong tile is ~ 1 : 1.25
        final double availableW = constraints.maxWidth - 24;
        final double availableH = constraints.maxHeight - 24;

        double tileW = availableW / gridWidth;
        double tileH = tileW * 1.28;

        if (tileH * gridHeight > availableH) {
          tileH = availableH / gridHeight;
          tileW = tileH / 1.28;
        }

        // Clamp tile size for good touch targets and visual clarity
        tileW = tileW.clamp(32.0, 72.0);
        tileH = tileH.clamp(40.0, 92.0);

        final double boardPixelW = gridWidth * tileW;
        final double boardPixelH = gridHeight * tileH;

        final double originX = (constraints.maxWidth - boardPixelW) / 2 - (minX * tileW) + (tileW * 0.3);
        final double originY = (constraints.maxHeight - boardPixelH) / 2 - (minY * tileH) + (tileH * 0.3);

        return GestureDetector(
          onTapUp: (details) {
            _handleTap(details.localPosition, originX, originY, tileW, tileH);
          },
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                key: _paintKey,
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _MahjongPainter(
                  engine: widget.engine,
                  theme: widget.theme,
                  originX: originX,
                  originY: originY,
                  tileW: tileW,
                  tileH: tileH,
                  pulse: _pulseController.value,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleTap(
    Offset localPos,
    double originX,
    double originY,
    double tileW,
    double tileH,
  ) {
    // Reverse sort: top layer (Z descending), then foreground Y descending
    final sortedTiles = List<MahjongTile>.from(widget.engine.tiles)
      ..sort((a, b) {
        if (a.z != b.z) return b.z.compareTo(a.z);
        if (a.y != b.y) return b.y.compareTo(a.y);
        return b.x.compareTo(a.x);
      });

    for (final tile in sortedTiles) {
      if (tile.isRemoved) continue;

      final double zOffset = tile.z * 3.5;
      final double left = originX + (tile.x * tileW) - zOffset;
      final double top = originY + (tile.y * tileH) - (tile.z * 4.5);
      final rect = Rect.fromLTWH(left, top, tileW, tileH);

      if (rect.contains(localPos)) {
        final renderBox = _paintKey.currentContext?.findRenderObject() as RenderBox?;
        final globalPos = renderBox != null
            ? renderBox.localToGlobal(rect.center)
            : rect.center;

        widget.onTileTapped(tile, globalPos);
        return;
      }
    }
  }
}

class _MahjongPainter extends CustomPainter {
  final MahjongEngine engine;
  final GameTheme theme;
  final double originX;
  final double originY;
  final double tileW;
  final double tileH;
  final double pulse;

  _MahjongPainter({
    required this.engine,
    required this.theme,
    required this.originX,
    required this.originY,
    required this.tileW,
    required this.tileH,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle board mat
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = theme.boardBackgroundColor.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = theme.gridLineColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 2. Sort tiles in painter order:
    // Z ascending (bottom to top), Y ascending (top to bottom), X ascending (left to right)
    final sortedTiles = List<MahjongTile>.from(engine.tiles)
      ..sort((a, b) {
        if (a.z != b.z) return a.z.compareTo(b.z);
        if (a.y != b.y) return a.y.compareTo(b.y);
        return a.x.compareTo(b.x);
      });

    final activeHintSet = engine.activeHint != null
        ? {engine.activeHint![0].id, engine.activeHint![1].id}
        : <String>{};

    for (final tile in sortedTiles) {
      if (tile.isRemoved) continue;

      final bool isFree = engine.isTileFree(tile);
      final bool isSelected = tile.isSelected;
      final bool isHinted = activeHintSet.contains(tile.id);

      final double zOffset = tile.z * 3.5;
      final double selectLift = isSelected ? 4.0 : 0.0;
      final double left = originX + (tile.x * tileW) - zOffset;
      final double top = originY + (tile.y * tileH) - (tile.z * 4.5) - selectLift;
      final rect = Rect.fromLTWH(left, top, tileW, tileH);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6.0));

      // --- Draw Soft Drop Shadow ---
      final double shadowOffset = 3.0 + (tile.z * 2.0) + (isSelected ? 3.0 : 0.0);
      final shadowRect = RRect.fromRectAndRadius(
        rect.shift(Offset(shadowOffset, shadowOffset)),
        const Radius.circular(6.0),
      );
      canvas.drawRRect(
        shadowRect,
        Paint()
          ..color = Colors.black.withOpacity(0.32 + (tile.z * 0.08))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5 + tile.z * 1.5),
      );

      // --- Draw Tile Image or Vector Fallback ---
      final ui.Image? sprite = SpriteManager.getTileImage(
        theme.tileFolder,
        tile.category,
        tile.value,
      );

      if (sprite != null) {
        final src = Rect.fromLTWH(
          0,
          0,
          sprite.width.toDouble(),
          sprite.height.toDouble(),
        );

        final paint = Paint()..filterQuality = FilterQuality.medium;

        // Subtle shaded contrast for blocked tiles so free tiles are instantly readable
        if (!isFree) {
          paint.color = const Color.fromRGBO(210, 210, 210, 0.88);
        }

        canvas.drawImageRect(sprite, src, rect, paint);
      } else {
        // High quality procedural tile fallback
        _drawProceduralTile(canvas, rrect, tile, isFree);
      }

      // --- Selection Highlight (Glow border) ---
      if (isSelected) {
        final glowPaint = Paint()
          ..color = theme.tileHighlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        canvas.drawRRect(rrect, glowPaint);

        // Soft internal gold sheen
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = theme.tileHighlightColor.withOpacity(0.18)
            ..style = PaintingStyle.fill,
        );
      }

      // --- Hint Highlight (Breathing gold border) ---
      if (isHinted) {
        final double glowAlpha = 0.55 + (pulse * 0.45);
        final hintPaint = Paint()
          ..color = const Color(0xFFFFD700).withOpacity(glowAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 + (pulse * 1.2);
        canvas.drawRRect(rrect, hintPaint);
      }
    }
  }

  void _drawProceduralTile(
    Canvas canvas,
    RRect rrect,
    MahjongTile tile,
    bool isFree,
  ) {
    // 3D Bevel Body
    final bodyPaint = Paint()
      ..color = isFree ? const Color(0xFFFBFBF8) : const Color(0xFFD6D6D0)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bodyPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // Text Symbol
    final textSpan = TextSpan(
      text: '${tile.category[0].toUpperCase()}${tile.value}',
      style: TextStyle(
        color: _getCategoryColor(tile.category),
        fontSize: tileH * 0.28,
        fontWeight: FontWeight.w800,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        rrect.center.dx - tp.width / 2,
        rrect.center.dy - tp.height / 2,
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'wan':
        return const Color(0xFFD32F2F);
      case 'bamboo':
        return const Color(0xFF388E3C);
      case 'dot':
        return const Color(0xFF1976D2);
      case 'dragon':
        return const Color(0xFFE64A19);
      case 'wind':
        return const Color(0xFF5D4037);
      case 'season':
        return const Color(0xFF7B1FA2);
      case 'flower':
        return const Color(0xFFC2185B);
      default:
        return Colors.black87;
    }
  }

  @override
  bool shouldRepaint(covariant _MahjongPainter oldDelegate) {
    return true;
  }
}
