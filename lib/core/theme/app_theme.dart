import 'package:flutter/material.dart';

class AppTheme {
  // Светлая тема
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Использование Material 3
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0, // Без тени
      centerTitle: true, // Заголовок по центру
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );

  // Темная тема
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );
}