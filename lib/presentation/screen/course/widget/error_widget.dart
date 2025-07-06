import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final double iconSize;
  final double verticalPadding;

  const ErrorView({
    super.key,
    required this.message,
    this.iconSize = 40,
    this.verticalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: iconSize,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
