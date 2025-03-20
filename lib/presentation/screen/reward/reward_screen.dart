import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/reward/reward_service.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final RewardService _rewardService = RewardService();
  int userPoints = 0;
  String lastClaimed = "";
  List<String> days = ["S", "M", "T", "W", "T", "F", "S"];
  List<bool> claimedDays = List.generate(7, (index) => false);

  @override
  void initState() {
    super.initState();
    _fetchRewardStatus();
  }

  Future<void> _fetchRewardStatus() async {
    int points = await _rewardService.getUserPoints();
    String lastClaim = await _rewardService.getLastClaimedDate();

    setState(() {
      userPoints = points;
      lastClaimed = lastClaim;

      DateTime today = DateTime.now();
      int currentWeekday = today.weekday; // 1 (Monday) - 7 (Sunday)

      for (int i = 0; i < 7; i++) {
        DateTime day = today.subtract(Duration(days: currentWeekday - (i + 1)));
        String dayStr = DateFormat('yyyy-MM-dd').format(day);
        claimedDays[i] = lastClaimed == dayStr;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text("Daily Reward"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.pink), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.pink), label: ""),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/avatar.jpg'), // Ganti dengan foto user
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jane Cooper",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("1 month ago",
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
