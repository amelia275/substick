import 'package:flutter/material.dart';
import 'package:substack_app/features/notes_detail/reply_feed_screen.dart';
import 'package:substack_app/features/read/read_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/read/read_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'package:substack_app/features/profile/profile_screen.dart';

class SubstackApp extends StatelessWidget {
  const SubstackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      title: 'Substack Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
