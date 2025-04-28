import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/core/theme/app_theme.dart';
import 'package:sport_equipment_rent/core/config/firebase_config.dart';
import 'package:sport_equipment_rent/features/auth/screens/sign_in_screen.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/data/models/user_role.dart';
import 'package:sport_equipment_rent/features/home/screens/home_screen.dart';
import 'package:sport_equipment_rent/features/home/screens/owner_home_screen.dart';
import 'package:sport_equipment_rent/data/providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await FirebaseConfig.init();
  print('Firebase initialized successfully!');

  // Инициализация русской локализации для timeago
  timeago.setLocaleMessages('ru', timeago.RuMessages());

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Sport Equipment Rental',
          theme: AppTheme.lightTheme,
          //darkTheme: AppTheme.darkTheme,
          // Добавляем поддержку русского языка
          locale: const Locale('ru', 'RU'),
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.watch(userProvider);

              return userAsync.when(
                data: (user) {
                  if (user == null) {
                    return const SignInScreen();
                  }
                  return user.role == UserRole.owner
                      ? const OwnerHomeScreen()
                      : const HomeScreen();
                },
                loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Scaffold(
                  body: Center(
                    child: Text('Ошибка: $error'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}