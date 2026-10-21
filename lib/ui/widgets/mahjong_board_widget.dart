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

class _MahjongBoardWidgetState extends State<MahjongBoardWidget> {
  final TransformationController _transController = TransformationController();
  final GlobalKey _paintKey = GlobalKey();

  double _tileW = 60.0;
  double _tileH = 80.4;
  double _minX = 0, _minY = 0;
  double _gridW = 8, _gridH = 8;

  @override
  void initState() {
    super.initState();
    _calculateBounds();
  }

  @override
  void didUpdateWidget(covariant MahjongBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.engine.layout.id != widget.engine.layout.id) {
      _calculateBounds();
      _transController.value = Matrix4.identity();
    }
  }

  void _calculateBounds() {
    double minX = 999, maxX = -999, minY = 999, maxY = -999;
    for (final slot in widget.engine.layout.slots) {
      if (slot.x < minX) minX = slot.x;
      if (slot.x > maxX) maxX = slot.x;
      if (slot.y < minY) minY = slot.y;
      if (slot.y > maxY) maxY = slot.y;
    }
    _minX = minX;
    _minY = minY;
    _gridW = (maxX - minX + 1.0);
    _gridH = (maxY - minY + 1.0);
  }

  void _resetZoom() {
    setState(() {
      _transController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    final currentMatrix = _transController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale < 2.5) {
      final newScale = currentScale * 1.25;
      setState(() {
        _transController.value = Matrix4.identity()
          ..translate(currentMatrix.getTranslation().x, currentMatrix.getTranslation().y)
          ..scale(newScale);
      });
    }
  }

  void _zoomOut() {
    final currentMatrix = _transController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale > 0.85) {
      final newScale = currentScale * 0.80;
      setState(() {
        _transController.value = Matrix4.identity()
          ..translate(currentMatrix.getTranslation().x, currentMatrix.getTranslation().y)
          ..scale(newScale);
      });
    } else {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availW = constraints.maxWidth - 12;
        final double availH = constraints.maxHeight - 12;

        // Giant, screen-filling mobile tile sizing (Hungry Studio style)
        double optimalW = availW / (_gridW + 0.15);
        double optimalH = optimalW * 1.34;

        final double maxLayerLift = widget.engine.layout.layers * 4.5;
        final double totalH = (_gridH * optimalH) + maxLayerLift;

        if (totalH > availH) {
          optimalH = (availH - maxLayerLift) / (_gridH + 0.15);
          optimalW = optimalH / 1.34;
        }

        _tileW = optimalW;
        _tileH = optimalH;

        final double boardPixelW = _gridW * _tileW;
        final double boardPixelH = (_gridH * _tileH) + maxLayerLift;

        // Perfectly centered on the mobile display
        final double originX = (constraints.maxWidth - boardPixelW) / 2 - (_minX * _tileW);
        final double originY = (constraints.maxHeight - boardPixelH) / 2 - (_minY * _tileH);

        return Stack(
          children: [
            // Interactive Pan & Zoom Area (Fill screen with zero margins)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: widget.theme.boardBackgroundColor.withOpacity(0.35),
                child: InteractiveViewer(
                  transformationController: _transController,
                  minScale: 0.8,
                  maxScale: 2.8,
                  boundaryMargin: const EdgeInsets.all(40),
                  constrained: true,
                  child: GestureDetector(
                    onDoubleTap: _resetZoom,
                    onTapUp: (details) {
                      _handleTap(details.localPosition, originX, originY, _tileW, _tileH);
                    },
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: CustomPaint(
                          key: _paintKey,
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _MahjongPainter(
                            engine: widget.engine,
                            theme: widget.theme,
                            originX: originX,
                            originY: originY,
                            tileW: _tileW,
                            tileH: _tileH,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Zoom Controls (Bottom Right)
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildZoomButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Zoom In',
                    onTap: _zoomIn,
                  ),
                  const SizedBox(height: 6),
                  _buildZoomButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Zoom Out',
                    onTap: _zoomOut,
                  ),
                  const SizedBox(height: 6),
                  _buildZoomButton(
                    icon: Icons.filter_center_focus_rounded,
                    tooltip: 'Fit Screen',
                    onTap: _resetZoom,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.theme.cardBackgroundColor.withOpacity(0.90),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.tileHighlightColor.withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: widget.theme.primaryTextColor,
          ),
        ),
      ),
    );
  }

  void _handleTap(
    Offset localPos,
    double originX,
    double originY,
    double tileW,
    double tileH,
  ) {
    // Top-most layer first: widget.engine.sortedTiles.reversed is already Z descending, Y descending
    for (final tile in widget.engine.sortedTiles.reversed) {
      if (tile.isRemoved) continue;

      final double zOffset = tile.z * 3.5;
      final double selectLift = tile.isSelected ? 6.0 : 0.0;
      final double left = originX + (tile.x * tileW) - zOffset;
      final double top = originY + (tile.y * tileH) - (tile.z * 4.5) - selectLift;
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

  // Static preallocated Paint singletons to guarantee 0 GC pressure on budget devices
  static final Paint _shadowPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _spritePaint = Paint()..filterQuality = FilterQuality.medium;
  static final Paint _blockedVeilPaint = Paint()
    ..color = const Color(0x7A000000)
    ..style = PaintingStyle.fill;
  static final Paint _freeRimPaint = Paint()
    ..color = const Color(0x61FFD54F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  static final Paint _selectionBorderPaint = Paint()
    ..color = const Color(0xFFFFD700)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5;
  static final Paint _selectionSheenPaint = Paint()
    ..color = const Color(0x33FFD700)
    ..style = PaintingStyle.fill;
  static final Paint _hintBorderPaint = Paint()
    ..color = const Color(0xFFFFC107)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5;

  static final List<Color> _cachedShadowColors = List.generate(
    10,
    (z) => Colors.black.withOpacity((0.30 + (z * 0.07)).clamp(0.0, 0.85)),
  );

  static final Paint _procBodyFreePaint = Paint()
    ..color = const Color(0xFFFBFBF8)
    ..style = PaintingStyle.fill;
  static final Paint _procBodyBlockedPaint = Paint()
    ..color = const Color(0xFFBDBDB8)
    ..style = PaintingStyle.fill;
  static final Paint _procBorderPaint = Paint()
    ..color = const Color(0xFF8D8D8D)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  _MahjongPainter({
    required this.engine,
    required this.theme,
    required this.originX,
    required this.originY,
    required this.tileW,
    required this.tileH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Engine cached sorted tiles (z ascending, y ascending) - 0 sorting or allocation overhead
    final activeHintSet = engine.activeHint != null
        ? {engine.activeHint![0].id, engine.activeHint![1].id}
        : const <String>{};

    for (final tile in engine.sortedTiles) {
      if (tile.isRemoved) continue;

      final bool isFree = engine.isTileFree(tile);
      final bool isSelected = tile.isSelected;
      final bool isHinted = activeHintSet.contains(tile.id);

      final double zOffset = tile.z * 3.5;
      final double selectLift = isSelected ? 6.0 : 0.0;
      final double left = originX + (tile.x * tileW) - zOffset;
      final double top = originY + (tile.y * tileH) - (tile.z * 4.5) - selectLift;
      final rect = Rect.fromLTWH(left, top, tileW, tileH);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6.0));

      // --- 1. Hardware-Accelerated 3D Directional Drop Shadow ---
      final double shadowOffset = 2.0 + (tile.z * 3.0) + (isSelected ? 5.0 : 0.0);
      final shadowRect = RRect.fromRectAndRadius(
        rect.shift(Offset(shadowOffset, shadowOffset)),
        const Radius.circular(6.0),
      );
      final int zIndex = tile.z.clamp(0, 9);
      _shadowPaint.color = _cachedShadowColors[zIndex];
      canvas.drawRRect(shadowRect, _shadowPaint);

      // --- 2. 3D PNG Sprite Texture ---
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

        canvas.drawImageRect(sprite, src, rect, _spritePaint);

        // --- VISUAL COMFORT & CONTRAST FILTER ---
        if (!isFree) {
          // Blocked tile: Soft dark-glass translucent veil
          canvas.drawRRect(rrect, _blockedVeilPaint);
        } else {
          // Free tile: Gentle warm golden rim spark
          canvas.drawRRect(rrect, _freeRimPaint);
        }
      } else {
        // Fallback procedural tile
        _drawProceduralTile(canvas, rrect, tile, isFree);
      }

      // --- 3. Selection Highlight ---
      if (isSelected) {
        canvas.drawRRect(rrect, _selectionBorderPaint);
        canvas.drawRRect(rrect, _selectionSheenPaint);
      }

      // --- 4. Hint Highlight ---
      if (isHinted) {
        canvas.drawRRect(rrect, _hintBorderPaint);
      }
    }
  }

  void _drawProceduralTile(
    Canvas canvas,
    RRect rrect,
    MahjongTile tile,
    bool isFree,
  ) {
    canvas.drawRRect(rrect, isFree ? _procBodyFreePaint : _procBodyBlockedPaint);
    canvas.drawRRect(rrect, _procBorderPaint);

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
