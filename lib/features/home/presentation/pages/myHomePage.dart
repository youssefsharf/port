import 'package:flutter/material.dart';

import '../widgets/square.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(7), // زوايا دائرية أكثر
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 16,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Hisabat',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600
                ? 2
                : 1; // أعمدة أكثر عند الشاشة العريضة
            return GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 1.5, // نسبة العرض إلى الارتفاع
              children: [
                Square(
                  title: 'اليومية',
                  color: Color(0xFF4A958D),
                  icon: Icons.calendar_today,
                ),
                Square(
                  title: 'الذمم',
                  color: Color(0xFF63CCCA),
                  icon: Icons.account_balance,
                ),
                Square(
                  title: 'الورشة',
                  color: Color(0xFF5DA399),
                  icon: Icons.build,
                ),
                Square(
                  title: 'المكتب',
                  color: Color(0xFF42858C),
                  icon: Icons.business,
                ),

              ],
            );
          },
        ),
      ),
    );
  }
}