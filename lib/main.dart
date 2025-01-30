import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:godtrain/screeens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCq02M9P6NpNl_tXDyYE1DN3wKrhMkVKMw",
    authDomain: "trainingapp-e7b76.firebaseapp.com",
    projectId: "trainingapp-e7b76",
    storageBucket: "trainingapp-e7b76.firebasestorage.app",
    messagingSenderId: "889910640111",
    appId: "1:889910640111:web:ad65a63cbab0423ebc4a1a",
    measurementId: "G-DXZTQ5S0XF",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(),
    );
  }
}