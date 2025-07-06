import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';

class LoadingView extends StatelessWidget {
  final double verticalPadding;

  const LoadingView({super.key, this.verticalPadding = 20});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(MyColor.primaryColor),
        ),
      ),
    );
  }
}
