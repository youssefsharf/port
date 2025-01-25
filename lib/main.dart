import 'package:flutter/material.dart';
import 'features/home/presentation/pages/myHomePage.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar', 'EG'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        primarySwatch: customColor,
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
              color: Color(0xFF031B29),               // اللون
    fontSize: 20,                            // حجم الخط
    fontWeight: FontWeight.bold,

            // الخط العريض (بولد)
   // fontStyle: FontStyle.italic,             // جعل النص مائل
   // letterSpacing: 2.0,                      // التباعد بين الحروف
    height: 1.5,                             // التباعد بين الأسطر
   ),
        ),
      ),
      home: const MyHomePage(), // العرض المباشر للصفحة الرئيسية
    );
  }
}




Map<int, Color> color =
{
  50:Color.fromRGBO(3, 27, 41, .1),
  100:Color.fromRGBO(3, 27, 41, .2),
  200:Color.fromRGBO(3, 27, 41, .3),
  300:Color.fromRGBO(3, 27, 41, .4),
  400:Color.fromRGBO(3, 27, 41, .5),
  500:Color.fromRGBO(3, 27, 41, .6),
  600:Color.fromRGBO(3, 27, 41, .7),
  700:Color.fromRGBO(3, 27, 41, .8),
  800:Color.fromRGBO(3, 27, 41, .9),
  900:Color.fromRGBO(3, 27, 41, 1),
};

MaterialColor customColor = MaterialColor(0xFF031B29, color);
