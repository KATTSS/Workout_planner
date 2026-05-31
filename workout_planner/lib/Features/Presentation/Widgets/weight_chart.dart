import 'package:flutter/material.dart';

class WeightChart extends StatelessWidget {
  final List<double> weights;
  final List<String>? dates;

  const WeightChart({super.key, required this.weights, this.dates});

  @override
  Widget build(BuildContext context) {
    if (weights.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No weight history data')),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(
        left: 40.0,
        right: 16,
        top: 16,
        bottom: 40,
      ),
      child: CustomPaint(
        painter: _WeightChartPainter(weights, dates),
        size: const Size(double.infinity, 200),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> weights;
  final List<String>? dates;

  _WeightChartPainter(this.weights, this.dates);

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final span = (maxW - minW).abs() < 0.1 ? 1.0 : (maxW - minW) * 1.1;
    final bottomMargin = minW - (span * 0.05);

    canvas.drawLine(Offset.zero, Offset(0, size.height), paintAxis);

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paintAxis,
    );

    final gridLines = 5;
    for (var i = 0; i <= gridLines; i++) {
      final ratio = i / gridLines;
      final y = size.height - (ratio * size.height);
      final weight = bottomMargin + (ratio * span);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);

      final textPainter = TextPainter(
        text: TextSpan(
          text: weight.toStringAsFixed(1),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-35, y - 5));
    }

    if (weights.isNotEmpty) {
      final dx = size.width / (weights.length > 1 ? weights.length - 1 : 1);

      final path = Path();
      for (var i = 0; i < weights.length; i++) {
        final x = dx * i;
        final normalizedY = (weights[i] - bottomMargin) / span;
        final y = size.height - (normalizedY * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        canvas.drawCircle(Offset(x, y), 4, paintPoint);
      }

      canvas.drawPath(path, paintLine);

      if (dates != null && dates!.isNotEmpty) {
        final labelSpacing = (weights.length > 6) ? (weights.length ~/ 3) : 1;
        for (var i = 0; i < weights.length; i += labelSpacing) {
          if (i < dates!.length) {
            final x = dx * i;
            final dateStr = _formatDate(dates![i]);
            final textPainter = TextPainter(
              text: TextSpan(
                text: dateStr,
                style: const TextStyle(color: Colors.grey, fontSize: 9),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(x - textPainter.width / 2, size.height + 5),
            );
          }
        }
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
