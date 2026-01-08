import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yunusco_accessories/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ SUCCESS: Firebase connected!');


  } catch (e) {
    print('❌ ERROR: $e');
  }
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yunusco Accessories',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SimpleSplashScreen(),
    );
  }
}




class SimpleSplashScreen extends StatefulWidget {
  @override
  _SimpleSplashScreenState createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFF2C5530),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.brush_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            SizedBox(height: 30),

            // Company Name
            Text(
              'Yunusco BD Ltd',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5530),
              ),
            ),

            SizedBox(height: 10),

            // Tagline
            Text(
              'Garments Accessories',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}