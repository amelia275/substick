import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

class SubstackApp extends StatelessWidget {
  const SubstackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Substack Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
