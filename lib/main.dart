import 'package:flutter/material.dart';
import 'scenes/profile/create.dart';
import 'scenes/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String age = '';

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAge = prefs.getInt('age')?.toString();

    setState(() {
      age = savedAge ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: age.isEmpty ? const CreateProfileScene() : const HomeScene(),
    );
  }
}
