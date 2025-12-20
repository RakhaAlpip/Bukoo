import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Import ini
import 'firebase_options.dart'; // Import file yang tadi error

import 'ui/pages/home_page.dart'; // Sesuaikan dengan struktur folder kamu

void main() async {
  // 1. Wajib tambahkan ini jika main() dijadikan async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase menggunakan file options tadi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Rental App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), 
    );
  }
}