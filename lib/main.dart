import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:appfreshfish/screens/splash/splash_screen.dart';
import 'package:appfreshfish/screens/auth/login_page.dart';
import 'package:appfreshfish/screens/pembeli/home_page.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await initializeDateFormatting('id_ID', null);

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  Future<bool> checkLogin() async {

    final pref =
        await SharedPreferences.getInstance();

    final isLogin =
    pref.getBool("isLogin");

    return isLogin == true;
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

    );
  }
}