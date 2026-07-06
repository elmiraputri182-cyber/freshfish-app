import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [

    {
      "icon": Icons.set_meal_rounded,
      "title": "Lihat Ikan Segar",
      "subtitle":
      "Pantau hasil tangkapan terbaru dari nelayan secara real-time.",
    },

    {
      "icon": Icons.shopping_cart_checkout_rounded,
      "title": "Pesan & Pre-Order",
      "subtitle":
      "Pesan ikan segar dengan mudah atau lakukan pre-order sebelum tersedia.",
    },

    {
      "icon": Icons.delivery_dining_rounded,
      "title": "Pengambilan Mudah",
      "subtitle":
      "Ambil langsung di tempat atau lakukan pengiriman ke lokasi tujuan.",
    },

  ];

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
                height: 145,
                width: 145,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // dekorasi bawah
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                height: 145,
                width: 145,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              children: [

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,

                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },

                    itemBuilder: (context, index) {

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            // icon card
                            Container(
                              height: 145,
                              width: 145,

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

                              child: Icon(
                                pages[index]["icon"],
                                color: Colors.white,
                                size: 85,
                              ),
                            ),

                            const SizedBox(height: 50),

                            Text(
                              pages[index]["title"],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1565C0),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              pages[index]["subtitle"],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.blueGrey,
                                height: 1.7,
                              ),
                            ),

                          ],
                        ),
                      );
                    },
                  ),
                ),

                // indikator titik
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: List.generate(
                    pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      margin: const EdgeInsets.symmetric(horizontal: 5),

                      width: currentPage == index ? 24 : 9,
                      height: 9,

                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Colors.blue
                            : Colors.blue.withOpacity(0.25),

                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // tombol
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),

                  child: SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 8,

                        shadowColor: Colors.blue.withOpacity(0.35),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {

                        if (currentPage == pages.length - 1) {

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );

                        } else {

                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );

                        }
                      },

                      child: Text(
                        currentPage == pages.length - 1
                            ? "Mulai Sekarang"
                            : "Lanjut",

                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

              ],
            ),
          ],
        ),
      ),
    );
  }
}