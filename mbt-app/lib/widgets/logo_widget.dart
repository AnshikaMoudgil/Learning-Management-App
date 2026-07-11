import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({Key? key, this.size = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
