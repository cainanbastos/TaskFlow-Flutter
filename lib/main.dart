import 'package:flutter/material.dart';

import 'screens/tarefas_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B9DFF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1120),
          centerTitle: false,
        ),
      ),
      home: const TarefasScreen(),
    );
  }
}
