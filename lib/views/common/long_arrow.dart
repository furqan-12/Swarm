import 'package:flutter/material.dart';

class LongArrowIcon extends StatelessWidget {
  final double length;
  final Color color;

  const LongArrowIcon({
    Key? key,
    required this.length,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(length, length / 2),
      painter: _LongArrowPainter(color),
    );
  }
}

class _LongArrowPainter extends CustomPainter {
  final Color color;

  _LongArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height / 10
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height / 2)
      ..lineTo(size.width, size.height / 2)
      ..moveTo(size.width * 0.9, size.height / 2)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..moveTo(size.width * 0.9, size.height / 2)
      ..lineTo(size.width * 0.7, size.height * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
