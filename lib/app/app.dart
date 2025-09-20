import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class TimmrApp extends StatelessWidget {
  const TimmrApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Timmr',
      routerConfig: router,
      theme: buildTheme(),
    );
  }
}
