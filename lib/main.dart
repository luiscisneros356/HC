import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hc_catamarca/data/services/firebase_service.dart';
import 'package:hc_catamarca/firebase_options.dart';
import 'package:hc_catamarca/view/loggin_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firebaseService = FirebaseService();

  runApp(
    ChangeNotifierProvider(
      create: (context) => firebaseService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Historia Clínica Digital',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
          elevation: 4,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {'/': (context) => const SimpleLocalLoginScreen()},
    );
  }
}
