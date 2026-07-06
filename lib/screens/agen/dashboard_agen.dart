import 'package:flutter/material.dart';

import 'home_agen_page.dart';
import 'pesanan_masuk_page.dart';
import 'statistik_agen_page.dart';
import 'laporan_agen_page.dart';
import 'akun_agen_page.dart';

import '../../widgets/premium_navigation.dart';

class DashboardAgen extends StatefulWidget {
  const DashboardAgen({super.key});

  @override
  State<DashboardAgen> createState() => _DashboardAgenState();
}

class _DashboardAgenState extends State<DashboardAgen> {

  int currentIndex = 0;

  final List<Widget> pages = const [

    HomeAgenPage(),

    PesananMasukPage(),

    StatistikAgenPage(),

    LaporanAgenPage(),

    AkunAgenPage(),

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

        onTap: (index){

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
              Icons.shopping_basket_outlined,
              size: 26,
            ),

            selectedIcon: Icon(
              Icons.shopping_basket,
              size: 30,
            ),

            label: "Pesanan",

          ),

          NavigationDestination(

            icon: Icon(
              Icons.bar_chart_outlined,
              size: 26,
            ),

            selectedIcon: Icon(
              Icons.bar_chart,
              size: 30,
            ),

            label: "Statistik",

          ),

          NavigationDestination(

            icon: Icon(
              Icons.description_outlined,
              size: 26,
            ),

            selectedIcon: Icon(
              Icons.description,
              size: 30,
            ),

            label: "Laporan",

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

            label: "Akun",

          ),

        ],

      ),

    );

  }

}