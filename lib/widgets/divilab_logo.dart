import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiviLabLogo extends StatelessWidget {
  const DiviLabLogo({super.key, this.width = 200});
  final double width;

  static const assetPath = 'assets/images/divilab_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return SizedBox(
      width: width,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('DiViLab',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              SizedBox(width: 4),
              Icon(Icons.add_box_outlined, color: AppColors.primary, size: 30),
            ],
          ),
          Text('HEALTH TECH',
              style: TextStyle(
                  fontSize: 11, letterSpacing: 3, color: Colors.black54)),
        ],
      ),
    );
  }
}