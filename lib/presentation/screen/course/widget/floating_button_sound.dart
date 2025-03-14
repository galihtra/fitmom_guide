import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../../core/utils/my_color.dart';
import '../../sound/sound_screen.dart';

class FloatingButtonSound extends StatelessWidget {
  const FloatingButtonSound({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: MyColor.secondaryColor,
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.audio_file),
          label: "Tambah Sound",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SoundScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
