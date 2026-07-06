import 'dart:async';
import 'package:flutter/material.dart';
import 'package:appfreshfish/config/api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_page.dart';
import '../admin/dashboard_admin_page.dart';
import '../agen/dashboard_agen.dart';
import '../pembeli/pembeli_main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkRedirect();
  }

  Future<void> _checkRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool("isLogin") ?? false;
    final role = prefs.getString("role") ?? "";

    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (isLogin) {
        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else if (role == "agen") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardAgen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PembeliMainPage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [

            // dekorasi atas
            Positioned(
              top: -70,
              right: -60,
              child: Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // dekorasi bawah
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // wave bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // logo
                    Container(
                      height: 170,
                      width: 170,

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2196F3),
                            Color(0xFF03A9F4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        borderRadius: BorderRadius.circular(45),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          "${Api.baseUrl}/logo.png",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.set_meal_rounded,
                            color: Colors.white,
                            size: 90,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    // title
                    Text(
                      "FreshFish",
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1565C0),
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // subtitle
                    Text(
                      "Informasi dan Pemesanan\nIkan Segar",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: Colors.blueGrey,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 55),

                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.blue.shade400,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Memuat aplikasi...",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 45),

                    Text(
                      "Powered by Nelayan Tradisional Bengkalis",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}