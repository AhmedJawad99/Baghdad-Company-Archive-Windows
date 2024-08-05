import 'package:baghdadcompany/firebase_options.dart';
import 'package:baghdadcompany/screens/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

final ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(147, 0, 134, 224),
  //surface: const Color.fromARGB(255, 57, 47, 68),
  brightness: Brightness.dark,
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شركة بغداد العراق للنقل العام والاستثمارات العقارية',
      theme: ThemeData().copyWith(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        textTheme: GoogleFonts.almaraiTextTheme(
          Theme.of(context).textTheme.copyWith(
                titleSmall: const TextStyle(color: Colors.white),
                titleMedium: const TextStyle(color: Colors.white),
                titleLarge: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                bodySmall: const TextStyle(color: Colors.white),
                bodyMedium: const TextStyle(color: Colors.white),
                bodyLarge: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
        ),
        cardTheme: const CardTheme().copyWith(color: colorScheme.onSecondary),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}
