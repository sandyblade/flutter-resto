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
        borderRadius: BorderRadius.circular(8),
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
