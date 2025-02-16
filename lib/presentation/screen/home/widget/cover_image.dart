import 'package:fitmom_guide/core/utils/my_images.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/dimensions.dart';

Widget coverImage() => Container(
      color: Colors.grey,
      child: Image.asset(
        MyImages.coverBg,
        width: double.infinity,
        height: Dimensions.coverHeight,
        fit: BoxFit.cover,
      ),
    );
