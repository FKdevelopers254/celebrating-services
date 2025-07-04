import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/route.dart';
import 'package:flutter/material.dart';

import 'l10n/supported_languages.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return MaterialApp(
      title: 'Celebrating',
      theme: AppTheme.lightTheme,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      locale: appState.locale,
      supportedLocales: supportedLanguages.map((l) => Locale(l.code)).toList(),
      home: const SplashScreen(),
    );
  }
}
