import 'package:flutter/material.dart';

class RewardTracker extends StatelessWidget {
  final List<bool> claimedDays;

  const RewardTracker({Key? key, required this.claimedDays}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> days = ["S", "M", "T", "W", "T", "F", "S"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.pinkAccent),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                return Column(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: claimedDays[index] ? Colors.orange : Colors.black,
                      size: 30,
                    ),
                    Text(days[index], style: const TextStyle(fontSize: 16)),
                  ],
                );
              }),
            ),
            const SizedBox(height: 5),
            const Text(
              "JADWAL LATIHAN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
