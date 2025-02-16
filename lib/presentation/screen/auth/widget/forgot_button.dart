import 'package:flutter/material.dart';

import '../../../../core/utils/style.dart';

class ForgotButton extends StatelessWidget {
  const ForgotButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text("Lupa Password?", style: boldMediumLarge),
    );
  }
}
