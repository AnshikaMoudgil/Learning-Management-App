import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WaveBackground extends StatelessWidget {
  final Widget child;
  const WaveBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: FlowyBackgroundPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class FlowyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint getWavePaint(List<Color> colors) {
      return Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
    }

    final paint1 = getWavePaint([
      AppColors.primaryBlue.withOpacity(0.015),
      AppColors.primaryBlue.withOpacity(0.03),
    ]);

    final paint2 = getWavePaint([
      AppColors.primaryBlue.withOpacity(0.03),
      AppColors.primaryBlue.withOpacity(0.06),
    ]);

    final paint3 = getWavePaint([
      AppColors.primaryBlue.withOpacity(0.06),
      AppColors.primaryBlue.withOpacity(0.12),
    ]);

    // Layer 1 (Back)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.65);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.85, size.width * 0.55, size.height * 0.65);
    path1.quadraticBezierTo(size.width * 0.85, size.height * 0.45, size.width, size.height * 0.75);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Layer 2 (Middle)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.5, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 1.0, size.width, size.height * 0.85);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Layer 3 (Front)
    final path3 = Path();
    path3.moveTo(0, size.height * 0.85);
    path3.quadraticBezierTo(size.width * 0.3, size.height * 1.0, size.width * 0.7, size.height * 0.85);
    path3.quadraticBezierTo(size.width * 0.9, size.height * 0.75, size.width, size.height * 0.9);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);

    // Dotted Pattern
    final dotPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Top Right
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.75 + i * 15, size.height * 0.02 + j * 15),
          1.5,
          dotPaint,
        );
      }
    }

    // Bottom Left
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.05 + i * 15, size.height * 0.7 + j * 15),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
