import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LanguageChip extends StatelessWidget {
  const LanguageChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: 22,
              height: 22,
              child: Column(
                children: [
                  Expanded(child: ColoredBox(color: Color(0xFFEF4B5F), child: SizedBox.expand())),
                  Expanded(child: ColoredBox(color: Color(0xFFD9D9D9), child: SizedBox.expand())),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Text('Bahasa', style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}