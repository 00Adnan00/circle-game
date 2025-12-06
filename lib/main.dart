import 'package:flutter/foundation.dart';
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
  bool _gameOver = false;

  double _calculateAccuracy() {
    final c = _center;
    if (c == null || points.isEmpty) return 0;
    final distances = points.map((p) => (p - c).distance).toList();
    final radius = distances.reduce((a, b) => a + b) / distances.length;
    const tolerance = 10.0; // pixels (try 8..20 depending on brush size)
    final hitCount = distances.where((d) => (d - radius).abs() <= tolerance).length;
    return (hitCount / distances.length) * 100;
  }

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
              points = [...points, details.localPosition];
            });
          },
          onPanUpdate: (details) {
            if (_gameOver) {
              return;
            }
            setState(() {
              points = [...points, details.localPosition];
            });
          },
          onPanEnd: (details) {
            setState(() {
              _gameOver = true;
            });
            if (_gameOver) {
              return;
            }
            setState(() {
              points = [...points, details.localPosition];
            });
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
    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (final point in points) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = brushColor
          ..strokeWidth = 10
          ..style = .stroke,
      );
    }
    canvas.drawCircle(center, 10, Paint()..color = Colors.black.withValues(alpha: .5));
  }

  @override
  bool shouldRepaint(covariant CavasPainter oldDelegate) {
    return !listEquals(oldDelegate.points, points);
  }
}
