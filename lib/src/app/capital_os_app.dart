import 'package:flutter/material.dart';

import '../features/auth/auth_gate.dart';
import 'capital_os_theme.dart';

class CapitalOsApp extends StatelessWidget {
  const CapitalOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlgoForce CapitalOS',
      theme: CapitalOsTheme.light,
      home: const AuthGate(),
    );
  }
}
