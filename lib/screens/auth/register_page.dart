import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();

}

class _RegisterPageState
    extends State<RegisterPage> {

  final username =
      TextEditingController();

  final password =
      TextEditingController();

  final namaLengkap =
      TextEditingController();

  final noTelp =
      TextEditingController();

  final alamat =
      TextEditingController();

  bool obscurePassword = true;

  bool isLoading = false;

  String role = "pembeli";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [

              Color(0xff1976D2),

              Color(0xff42A5F5),

              Color(0xffE3F2FD),

            ],

          ),

        ),

        child: SafeArea(

          child: SingleChildScrollView(

            padding: const EdgeInsets.symmetric(

              horizontal: 25,

              vertical: 30,

            ),

            child: Column(

              children: [

                const SizedBox(height: 15),

                //----------------------------------
                // LOGO
                //----------------------------------

                Hero(

                  tag: "logo",

                  child: Container(

                    width: 110,

                    height: 110,

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(30),

                      boxShadow: [

                        BoxShadow(

                          color:
                              Colors.black.withOpacity(.12),

                          blurRadius: 20,

                          offset:
                              const Offset(0, 8),

                        ),

                      ],

                    ),

                    child: const Icon(

                      Icons.person_add_alt_1,

                      color: Colors.blue,

                      size: 58,

                    ),

                  ),

                ),

                const SizedBox(height: 25),

                Text(

                  "Create Account",

                  style: GoogleFonts.poppins(

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,

                    color: Colors.white,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  "Daftar untuk mulai menggunakan\nFresh Fish",

                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(

                    color: Colors.white70,

                    fontSize: 14,

                    height: 1.5,

                  ),

                ),

                const SizedBox(height: 35),

                //----------------------------------
                // CARD REGISTER
                //----------------------------------

                Container(

                  padding:
                      const EdgeInsets.all(25),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(28),

                    boxShadow: [

                      BoxShadow(

                        color:
                            Colors.black.withOpacity(.08),

                        blurRadius: 20,

                        offset:
                            const Offset(0, 8),

                      ),

                    ],

                  ),

                  child: Column(

                    children: [
                      //----------------------------------
                      // USERNAME
                      //----------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xff2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: username,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan email",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.blue.withOpacity(0.01),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xffEBF2FF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //----------------------------------
                      // PASSWORD
                      //----------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xff2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: password,
                        obscureText: obscurePassword,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan password",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.blue,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.blue.withOpacity(0.01),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xffEBF2FF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //----------------------------------
                      // ROLE
                      //----------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Daftar Sebagai",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xff2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: role,
                        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.groups_rounded,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.blue.withOpacity(0.01),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xffEBF2FF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "pembeli",
                            child: Text("Pembeli"),
                          ),
                          DropdownMenuItem(
                            value: "agen",
                            child: Text("Agen"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            role = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      //----------------------------------
                      // NAMA
                      //----------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Nama Lengkap",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xff2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: namaLengkap,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan nama lengkap",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.blue.withOpacity(0.01),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xffEBF2FF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //----------------------------------
                      // NO HP
                      //----------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Nomor Telepon",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xff2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: noTelp,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "08xxxxxxxxxx",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.blue.withOpacity(0.01),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xffEBF2FF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //----------------------------------
                      // ALAMAT
                      //----------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Alamat",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xff2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: alamat,
                        maxLines: 3,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Masukkan alamat lengkap",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 55),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.blue.withOpacity(0.01),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xffEBF2FF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
//----------------------------------
// TOMBOL REGISTER
//----------------------------------

SizedBox(

  width: double.infinity,

  height: 58,

  child: DecoratedBox(

    decoration: BoxDecoration(

      gradient: const LinearGradient(

        colors: [

          Color(0xff1976D2),

          Color(0xff42A5F5),

        ],

      ),

      borderRadius: BorderRadius.circular(18),

      boxShadow: [

        BoxShadow(

          color: Colors.blue.withOpacity(.35),

          blurRadius: 15,

          offset: const Offset(0, 6),

        ),

      ],

    ),

    child: ElevatedButton(

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.transparent,

        shadowColor: Colors.transparent,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(18),

        ),

      ),

      onPressed: isLoading
          ? null
          : () async {

              if (username.text.isEmpty ||
                  password.text.isEmpty ||
                  namaLengkap.text.isEmpty ||
                  noTelp.text.isEmpty ||
                  alamat.text.isEmpty) {

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(

                    content: Text(
                      "Semua data wajib diisi",
                    ),

                  ),

                );

                return;

              }

              setState(() {
                isLoading = true;
              });

              bool success = false;
              try {
                // 1. Register to Firebase Auth first
                final userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                  email: username.text,
                  password: password.text,
                ).timeout(const Duration(seconds: 15), onTimeout: () {
                   throw TimeoutException("Koneksi ke Firebase timeout. Periksa internet Anda.");
                 });

                if (userCredential.user != null) {
                  // 2. Register to MySQL database
                  success = await AuthService.register(
                    username.text,
                    password.text,
                    role,
                    namaLengkap.text,
                    noTelp.text,
                    alamat.text,
                  );

                  if (!success) {
                    // Clean up Firebase Auth user if MySQL fails
                    await userCredential.user!.delete();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Gagal menyimpan data ke database server."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              } on FirebaseAuthException catch (e) {
                String msg = "Registrasi gagal";
                if (e.code == 'weak-password') {
                  msg = "Password terlalu lemah (minimal 6 karakter).";
                } else if (e.code == 'email-already-in-use') {
                  msg = "Email sudah terdaftar.";
                } else if (e.code == 'invalid-email') {
                  msg = "Format email tidak valid.";
                } else {
                  msg = e.message ?? msg;
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              if (!mounted) return;

              setState(() {

                isLoading = false;

              });

              if (success) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  const SnackBar(

                    backgroundColor:
                        Colors.green,

                    content: Text(
                      "Register berhasil",
                    ),

                  ),

                );

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const LoginPage(),

                  ),

                );

              } else {

                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  const SnackBar(

                    backgroundColor:
                        Colors.red,

                    content: Text(
                      "Register gagal",
                    ),

                  ),

                );

              }

            },

      child: isLoading

          ? const SizedBox(

              width: 24,

              height: 24,

              child:
                  CircularProgressIndicator(

                color: Colors.white,

                strokeWidth: 2.5,

              ),

            )

          : Text(

              "REGISTER",

              style: GoogleFonts.poppins(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,

                color: Colors.white,

              ),

            ),

    ),

  ),

),

const SizedBox(height: 25),

//----------------------------------
// ATAU
//----------------------------------

Row(

  children: [

    Expanded(

      child: Divider(

        color: Colors.grey.shade300,

      ),

    ),

    Padding(

      padding:
          const EdgeInsets.symmetric(

        horizontal: 15,

      ),

      child: Text(

        "ATAU",

        style: GoogleFonts.poppins(

          color: Colors.grey,

        ),

      ),

    ),

    Expanded(

      child: Divider(

        color: Colors.grey.shade300,

      ),

    ),

  ],

),

const SizedBox(height: 25),

//----------------------------------
// LOGIN
//----------------------------------

Row(

  mainAxisAlignment:
      MainAxisAlignment.center,

  children: [

    Text(

      "Sudah punya akun?",

      style: GoogleFonts.poppins(

        color: Colors.grey.shade700,

      ),

    ),

    TextButton(

      onPressed: () {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const LoginPage(),

          ),

        );

      },

      child: Text(

        "Login",

        style: GoogleFonts.poppins(

          color: Colors.blue,

          fontWeight:
              FontWeight.bold,

        ),

      ),

    ),

  ],

),

],

),

),

const SizedBox(height: 35),

//----------------------------------
// FOOTER
//----------------------------------

Text(

  "Fresh Fish",

  style: GoogleFonts.poppins(

    color: const Color.fromARGB(255, 0, 0, 0),

    fontWeight: FontWeight.w600,

  ),

),

const SizedBox(height: 6),

Text(

  "Hubungkan pembeli dengan agen\nhasil laut terpercaya.",

  textAlign: TextAlign.center,

  style: GoogleFonts.poppins(

    color: const Color.fromARGB(179, 0, 0, 0),

    fontSize: 12,

    height: 1.5,

  ),

),

const SizedBox(height: 18),

Text(

  "© 2026 Fresh Fish. All Rights Reserved.",

  style: GoogleFonts.poppins(

    color: const Color.fromARGB(137, 0, 0, 0),

    fontSize: 11,

  ),

),

const SizedBox(height: 20),

],

),

),

),

),

);

}

}