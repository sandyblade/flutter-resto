/// This file is part of the Sandy Andryanto Resto Application.
///
/// Author:     Sandy Andryanto <sandy.andryanto.blade@gmail.com>
/// Copyright:  2025
///
/// For full copyright and license information,
/// please view the LICENSE.md file distributed with this source code.
///
import 'package:flutter/material.dart';

class MyAlert extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const MyAlert({
    required this.message,
    required this.color,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
