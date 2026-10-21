import 'dart:math';
import 'package:flutter/material.dart';

class FloatingScoreParticle {
  final Offset position;
  final String text;
  final Color color;
  final double startTime;

  FloatingScoreParticle({
    required this.position,
    required this.text,
    required this.color,
    required this.startTime,
  });
}

class ZenSparkleParticle {
  final Offset origin;
  final double angle;
  final double speed;
  final double maxRadius;
  final Color color;
  final double startTime;

  ZenSparkleParticle({
    required this.origin,
    required this.angle,
    required this.speed,
    required this.maxRadius,
    required this.color,
    required this.startTime,
  });
}

class ZenVfxOverlay extends StatefulWidget {
  final Widget child;
  final ZenVfxController controller;

  const ZenVfxOverlay({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ZenVfxOverlay> createState() => _ZenVfxOverlayState();
}

class ZenVfxController extends ChangeNotifier {
  final List<FloatingScoreParticle> _scores = [];
  final List<ZenSparkleParticle> _sparkles = [];
  String? _comboText;
  DateTime? _comboExpiry;

  void spawnMatchVfx({
    required Offset pos1,
    required Offset pos2,
    required int points,
    required int combo,
    required Color accentColor,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final rand = Random();

    // Floating score at midpoint
    final mid = Offset((pos1.dx + pos2.dx) / 2, (pos1.dy + pos2.dy) / 2);
    _scores.add(FloatingScoreParticle(
      position: mid,
      text: '+$points',
      color: accentColor,
      startTime: now,
    ));

    // Gentle, non-blinding sparkle particles around both tiles
    for (final pos in [pos1, pos2]) {
      for (int i = 0; i < 8; i++) {
        final angle = rand.nextDouble() * 2 * pi;
        final speed = 30.0 + rand.nextDouble() * 40.0;
        _sparkles.add(ZenSparkleParticle(
          origin: pos,
          angle: angle,
          speed: speed,
          maxRadius: 2.0 + rand.nextDouble() * 2.0,
          color: accentColor.withOpacity(0.85),
          startTime: now,
        ));
      }
    }

    if (combo >= 2) {
      _comboText = '$combo× COMBO!';
      _comboExpiry = DateTime.now().add(const Duration(milliseconds: 1400));
    } else {
      _comboText = null;
    }

    notifyListeners();
  }

  void clear() {
    _scores.clear();
    _sparkles.clear();
    _comboText = null;
    notifyListeners();
  }
}

class _ZenVfxOverlayState extends State<ZenVfxOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    widget.controller.addListener(_onVfxUpdate);
  }

  void _onVfxUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVfxUpdate);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Prune expired particles
    widget.controller._scores.removeWhere((p) => (now - p.startTime) > 1.2);
    widget.controller._sparkles.removeWhere((p) => (now - p.startTime) > 0.8);

    final showCombo = widget.controller._comboText != null &&
        widget.controller._comboExpiry != null &&
        DateTime.now().isBefore(widget.controller._comboExpiry!);

    return Stack(
      children: [
        widget.child,
        // Particle canvas
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _VfxPainter(
                    scores: widget.controller._scores,
                    sparkles: widget.controller._sparkles,
                    currentTime: DateTime.now().millisecondsSinceEpoch / 1000.0,
                  ),
                );
              },
            ),
          ),
        ),
        // Compact Combo Callout elevated ABOVE board (Alignment(0, -0.72))
        // Never covers tiles, zero blinding white flash!
        if (showCombo)
          Align(
            alignment: const Alignment(0, -0.72),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.0),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9800).withOpacity(0.95),
                          const Color(0xFFFF5722).withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.controller._comboText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _VfxPainter extends CustomPainter {
  final List<FloatingScoreParticle> scores;
  final List<ZenSparkleParticle> sparkles;
  final double currentTime;

  _VfxPainter({
    required this.scores,
    required this.sparkles,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw gentle sparkles
    for (final sp in sparkles) {
      final elapsed = currentTime - sp.startTime;
      if (elapsed < 0 || elapsed > 0.8) continue;
      final progress = elapsed / 0.8;
      final currentDist = sp.speed * elapsed;
      final dx = sp.origin.dx + cos(sp.angle) * currentDist;
      final dy = sp.origin.dy + sin(sp.angle) * currentDist;
      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final radius = sp.maxRadius * (1.0 - progress * 0.5);

      final paint = Paint()
        ..color = sp.color.withOpacity(alpha * 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }

    // 2. Draw floating scores
    for (final sc in scores) {
      final elapsed = currentTime - sc.startTime;
      if (elapsed < 0 || elapsed > 1.2) continue;
      final progress = elapsed / 1.2;
      final dy = sc.position.dy - (progress * 45.0);
      final alpha = (1.0 - progress).clamp(0.0, 1.0);

      final textSpan = TextSpan(
        text: sc.text,
        style: TextStyle(
          color: sc.color.withOpacity(alpha),
          fontSize: 20 + (1.0 - progress) * 4,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(alpha * 0.6),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(sc.position.dx - textPainter.width / 2, dy),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VfxPainter oldDelegate) => true;
}
