import 'package:flutter/material.dart';

import 'home_page.dart';
import 'riwayat_page.dart';
import 'info_harga_page.dart';
import 'profil_page.dart';
import '../../widgets/premium_navigation.dart';

class PembeliMainPage extends StatefulWidget {
  const PembeliMainPage({super.key});

  @override
  State<PembeliMainPage> createState() =>
      _PembeliMainPageState();
}

class _PembeliMainPageState
    extends State<PembeliMainPage> {

  int currentIndex = 0;

  final List<Widget> pages = const [

    HomePage(),

    RiwayatPage(),

    InfoHargaPage(),

    ProfilPage(),

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF5F7FB),

      body: IndexedStack(

        index: currentIndex,

        children: pages,

      ),

      bottomNavigationBar: PremiumNavigation(

    currentIndex: currentIndex,

    onTap: (index) {

      setState(() {

        currentIndex = index;

      });

    },

    destinations: const [

      NavigationDestination(

        icon: Icon(

          Icons.home_outlined,

          size: 26,

        ),

        selectedIcon: Icon(

          Icons.home_rounded,

          size: 30,

        ),

        label: "Beranda",

      ),

      NavigationDestination(

        icon: Icon(

          Icons.receipt_long_outlined,

          size: 26,

        ),

        selectedIcon: Icon(

          Icons.receipt_long,

          size: 30,

        ),

        label: "Riwayat",

      ),

      NavigationDestination(

        icon: Icon(

          Icons.set_meal_outlined,

          size: 26,

        ),

        selectedIcon: Icon(

          Icons.set_meal,

          size: 30,

        ),

        label: "Harga",

      ),

      NavigationDestination(

        icon: Icon(

          Icons.person_outline,

          size: 26,

        ),

        selectedIcon: Icon(

          Icons.person,

          size: 30,

        ),

        label: "Profil",

      ),

    ],

  ),
      );

    }

  }