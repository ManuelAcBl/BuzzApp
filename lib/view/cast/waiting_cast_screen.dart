import 'dart:math';

import 'package:buzz_app/view/widgets/stroke_text.dart';
import 'package:flutter/material.dart';

// class WaitingCastScreen extends StatelessWidget {
//   const WaitingCastScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.red.shade500,
//               Colors.red.shade900,
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: StrokeText(
//             stroke: Stroke(
//               color: Theme.of(context).primaryColor,
//               width: 5,
//             ),
//             text: Text(
//               "Buzz! App",
//               style: TextStyle(
//                 fontSize: 100,
//                 color: Theme.of(context).scaffoldBackgroundColor,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class WaitingCastScreen extends StatelessWidget {
  const WaitingCastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: TheaterCurtainPainter(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withAlpha(128), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: (2 * pi) * -0.02,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Buzz! App",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[200],
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.black.withOpacity(0.9),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "By ManuelAc",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[300],
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.8),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TheaterCurtainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [Colors.red[900]!, Colors.red[700]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Fondo del telón
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Pliegues superiores curvados
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    for (int i = 0; i < 5; i++) {
      final xStart = i * (size.width / 4);
      final xEnd = (i + 1) * (size.width / 4);
      path.quadraticBezierTo(
        xStart + (size.width / 8),
        size.height * 0.05,
        xEnd,
        size.height * 0.2,
      );
    }
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    final topPaint = Paint()
    ..color = Color(0xFF9e0000)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, topPaint);

    // Líneas verticales para simular pliegues
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 3;

    for (double i = size.width * 0.05; i < size.width; i += size.width * 0.1) {
      canvas.drawLine(Offset(i, size.height * 0.2), Offset(i, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
