// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Offset> points = [];

  Offset? _center;

  double _calculateAccuracy() {
    final c = _center;
    if (c == null || points.isEmpty) return 0;

    final distances = points.map((p) => (p - c).distance).toList();

    // Estimated radius of the drawn circle
    final radius = distances.reduce((a, b) => a + b) / distances.length;

    const tolerance = 10.0; // pixels (try 8..20 depending on brush size)

    final hitCount = distances.where((d) => (d - radius).abs() <= tolerance).length;

    return (hitCount / distances.length) * 100;
  }

  bool _gameOver = false;

  void _reset() {
    setState(() {
      points = [];
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GestureDetector(
          onPanStart: (details) {
            if (_gameOver) {
              return;
            }
            setState(() {
              points.add(details.localPosition);
            });
            log(details.localPosition.toString());
          },
          onPanUpdate: (details) {
            if (_gameOver) {
              return;
            }
            setState(() {
              points.add(details.localPosition);
            });
            log(details.localPosition.toString());
          },
          onPanEnd: (details) {
            setState(() {
              _gameOver = true;
            });
            if (_gameOver) {
              return;
            }
            setState(() {
              points.add(details.localPosition);
            });
            log(details.localPosition.toString());
          },
          child: Stack(
            children: [
              CustomPaint(
                painter: CavasPainter(
                  onCenterPointUpdate: (centerOffset) {
                    Future(
                      () {
                        setState(() {
                          _center = centerOffset;
                        });
                      },
                    );
                  },
                  points: points,
                  brushColor: Colors.amber,
                ),
                size: Size(double.infinity, double.infinity),
              ),
              Align(
                alignment: .topCenter,
                child: Text(
                  '%${_calculateAccuracy()}',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              if (_gameOver)
                Align(
                  alignment: .bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FilledButton(
                      onPressed: _reset,
                      child: Text('Reset'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CavasPainter extends CustomPainter {
  const CavasPainter({
    required this.points,
    required this.brushColor,
    required this.onCenterPointUpdate,
  });

  final List<Offset> points;
  final Color brushColor;
  final void Function(Offset offset)? onCenterPointUpdate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    onCenterPointUpdate?.call(center);

    if (points.length == 1) {
      canvas.drawCircle(points[0], 10, Paint()..color = brushColor);
    } else {
      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        canvas.drawLine(
          current,
          next,
          Paint()
            ..color = Colors.amber
            ..strokeWidth = 10,
        );
      }
    }
    canvas.drawCircle(center, 10, Paint()..color = Colors.black.withValues(alpha: .5));
  }

  @override
  bool shouldRepaint(covariant CavasPainter oldDelegate) {
    return true;
    // return !listEquals(oldDelegate.points, points);
  }
}

// class TriangelPainter extends CustomPainter {
//   const TriangelPainter({required this.color});
//   final Color color;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final trianglePaint = Paint()..color = color;

//     final path = Path()
//       ..moveTo(size.width / 2, 0)
//       ..lineTo(0, size.height)
//       ..lineTo(size.width, size.height)
//       ..lineTo(size.width / 2, 0)
//       ..close();

//     canvas.drawPath(path, trianglePaint);
//   }

//   @override
//   bool shouldRepaint(covariant TriangelPainter oldDelegate) {
//     return color != oldDelegate.color;
//   }
// }
