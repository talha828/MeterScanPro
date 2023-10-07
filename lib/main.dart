import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/view/fetch_data_screen/fetch_data_screen.dart';
import 'package:meter_scan/view/main_screen/main_screen.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme,),
        primaryTextTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        primarySwatch: createMaterialColor(themeColor1),
        buttonTheme:const ButtonThemeData(
          buttonColor: themeColor1,
        ),
        useMaterial3: true,
      ),
      home:const MainScreen(),
    );
  }
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}
