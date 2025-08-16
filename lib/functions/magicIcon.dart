import 'package:flutter/material.dart';

class MagicTIcon extends StatelessWidget {
  final double size;
  const MagicTIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MagicTPainter(),
    );
  }
}

class _MagicTPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw gray circle
    final circlePaint = Paint()..color = Colors.grey.shade400;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw "T" in the center
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'G',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.55,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);

    // Draw sparkle/star (simple cross shape) at top right
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;
    final sparkleCenter = Offset(size.width * 0.78, size.height * 0.22);
    final sparkleLen = size.width * 0.13;
    // Vertical
    canvas.drawLine(
      Offset(sparkleCenter.dx, sparkleCenter.dy - sparkleLen),
      Offset(sparkleCenter.dx, sparkleCenter.dy + sparkleLen),
      sparklePaint,
    );
    // Horizontal
    canvas.drawLine(
      Offset(sparkleCenter.dx - sparkleLen, sparkleCenter.dy),
      Offset(sparkleCenter.dx + sparkleLen, sparkleCenter.dy),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}