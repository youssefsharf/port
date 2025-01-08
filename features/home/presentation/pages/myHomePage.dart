import 'package:flutter/material.dart';

import '../../../dialy/presentation/pages/dailyPage.dart';
import '../widgets/square.dart';
// Assuming your custom GridTile widget is here

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Container
          (
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(7), // More rounded corners
            boxShadow: [ // Add a subtle shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 16,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: const Text(
              'دفتر اليوميه',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1,
          // Single column
          mainAxisSpacing: 16.0,
          // Spacing between squares
          crossAxisSpacing: 16.0,
          // Spacing between squares
          childAspectRatio: MediaQuery
              .of(context)
              .size
              .width / (MediaQuery
              .of(context)
              .size
              .height *0.22),
          // Dynamic aspect ratio
          children: [
            Square(
              title: 'اليومية',
              color: Colors.blue,
              icon: Icons.calendar_today, // Add appropriate icons
            ),
            Square(
              title: 'الذمم',
              color: Colors.green,
              icon: Icons.account_balance, // Add appropriate icons
            ),
            Square(
              title: 'الورشة',
              color: Colors.orange,
              icon: Icons.build, // Add appropriate icons
            ),
            Square(
              title: 'المكتب',
              color: Colors.purple,
              icon: Icons.business, // Add appropriate icons
            ),
          ],
        ),
      ),);
  }}