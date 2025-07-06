import 'package:flutter/material.dart';

class TestDiagram extends StatelessWidget {
  final int successTest;
  final int overallTest;

  const TestDiagram(
      {super.key, required this.overallTest, required this.successTest});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 100,
              padding: const EdgeInsets.fromLTRB(30, 23, 16, 16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar('$successTest tests complete',
                      Color(0xFF4AD968), successTest / overallTest),
                  const SizedBox(height: 12),
                  _buildProgressBar(
                      '${overallTest - successTest} tests failed',
                      Color(0xFFFF383C),
                      (overallTest - successTest) / overallTest),
                ],
              ),
            ),
            const SizedBox(width: 32),
            CustomPaint(
              size: const Size(115, 115),
              painter:
                  CircleChartPainter(successTest, overallTest - successTest),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, Color color, double value) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF898989), fontWeight: FontWeight.w400))
      ],
    );
  }
}

class CircleChartPainter extends CustomPainter {
  final int passed;
  final int failed;
  final double pi = 3.14159;

  CircleChartPainter(this.passed, this.failed);

  @override
  void paint(Canvas canvas, Size size) {
    final total = passed + failed;
    if (total == 0) return;

    final fullCircle = 2 * pi;
    final gap = 0.20;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (passed == 0 || failed == 0) {
      paint.color = passed == 0 ? Color(0xFFFF383C) : Color(0xFF4AD968);
      canvas.drawArc(rect, 0, fullCircle, false, paint);
      return;
    }
    final passedFraction = passed / total;
    final failedFraction = failed / total;

    final passedArc = fullCircle * passedFraction - gap;
    final failedArc = fullCircle * failedFraction - gap;

    final startAngle = -pi / 2 + gap / 2;

    paint.color = Color(0xFF4AD968);
    canvas.drawArc(rect, startAngle, passedArc, false, paint);

    paint.color = Color(0xFFFF383C);
    final nextStart = startAngle + passedArc + gap;
    canvas.drawArc(rect, nextStart, failedArc, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
