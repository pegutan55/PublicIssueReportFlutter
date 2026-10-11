import 'package:flutter/material.dart';

import 'map_screen.dart';

void main() {
  runApp(const PublicIssueReporterApp());
}

class PublicIssueReporterApp extends StatelessWidget {
  const PublicIssueReporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1769AA);
    const navy = Color(0xFF14273D);

    return MaterialApp(
      title: 'PublicIssueReporter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: navy,
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
      home: const MapScreen(),
    );
  }
}
