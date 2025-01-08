import 'package:flutter/material.dart';
import '../../../dialy/presentation/pages/dailyPage.dart'; // تأكد من أن الاستيراد صحيح

class Square extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon; // Add an icon parameter

  const Square({
    super.key,
    required this.title,
    required this.color,
    required this.icon, // Make icon required
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyPage(
              title: title, // Pass the title to the DailyPage
              tableColor: color, // Pass the color to the DailyPage
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30.0), // More rounded corners
          boxShadow: [ // Add a subtle shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50.0, // Adjust icon size if needed
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0, // Adjust font size for better readability
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
