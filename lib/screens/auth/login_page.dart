import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:appfreshfish/config/api.dart';

import '../../services/auth_service.dart';
import '../admin/dashboard_admin_page.dart';
import '../agen/dashboard_agen.dart';
import '../pembeli/pembeli_main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {

    if(usernameController.text.isEmpty ||
        passwordController.text.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Email dan Password wajib diisi"),

        ),

      );

      return;

    }

    setState(() {

      isLoading = true;

    });

    Map<String, dynamic> response = {"success": false};

    try {
      // 1. Authenticate with Firebase Auth first
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException("Koneksi ke Firebase timeout. Periksa internet Anda.");
      });

      if (userCredential.user != null) {
        // 2. Fetch MySQL profile data
        response = await AuthService.login(
          usernameController.text,
          passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Login gagal";
      if (e.code == 'user-not-found') {
        msg = "Email tidak terdaftar.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = "Password salah.";
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

    setState(() {

      isLoading = false;

    });

    if(!mounted) return;

    if(response["success"]==true){

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(

        "id_user",

        response["data"]["id_user"].toString(),

      );

      await prefs.setString(

        "nama",

        response["data"]["nama"] ?? "",

      );

      await prefs.setString(

        "nama_lengkap",

        response["data"]["nama"] ?? "",

      );

      await prefs.setString(

        "username",

        response["data"]["username"] ?? "",

      );

      await prefs.setString(

        "no_hp",

        response["data"]["no_hp"] ?? "",

      );

      await prefs.setString(

        "alamat",

        response["data"]["alamat"] ?? "",

      );

      String role = response["role"];

      await prefs.setString("role", role);
      await prefs.setBool("isLogin", true);

      if(role=="admin"){

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>

            const AdminDashboardPage(),

          ),

        );

      }else if(role=="agen"){

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>

            const DashboardAgen(),

          ),

        );

      }else{

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>

            const PembeliMainPage(),

          ),

        );

      }

    }else{

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          backgroundColor: Colors.red,

          content: Text(

            response["message"] ?? "Login gagal",

            style: GoogleFonts.poppins(),

          ),

        ),

      );

    }

  }

  Future<void> loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Google Sign In
      await GoogleSignIn.instance.initialize(
        serverClientId: "354395236058-fftrudqq0f00i6pt1ajv4ou5h55dj3jm.apps.googleusercontent.com",
      );
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 2. Sign in to Firebase Auth
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final String? email = userCredential.user?.email;
      final String? displayName = userCredential.user?.displayName;

      if (email != null) {
        // 3. Check if user exists in local MySQL database
        final response = await AuthService.loginGoogle(email);

        if (response["success"] == true) {
          // User exists! Save session and go to dashboard
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("id_user", response["data"]["id_user"].toString());
          if (response["data"]["id_agen"] != null) {
            await prefs.setString("id_agen", response["data"]["id_agen"].toString());
          }
          await prefs.setString("nama", response["data"]["nama"] ?? displayName ?? "");
          await prefs.setString("nama_lengkap", response["data"]["nama"] ?? displayName ?? "");
          await prefs.setString("username", response["data"]["username"] ?? email);
          await prefs.setString("no_hp", response["data"]["no_hp"] ?? "");
          await prefs.setString("alamat", response["data"]["alamat"] ?? "");
          
          String role = response["role"];
          await prefs.setString("role", role);
          await prefs.setBool("isLogin", true);

          if (!mounted) return;
          if (role == "admin") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
          } else if (role == "agen") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardAgen()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PembeliMainPage()));
          }
        } else {
          // User does NOT exist in MySQL!
          if (!mounted) return;
          showGoogleRegisterDialog(email, displayName ?? "");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Firebase Auth Error: ${e.message}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign In Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showGoogleRegisterDialog(String email, String defaultName) {
    String selectedRole = "pembeli";
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Lengkapi Profil Anda",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Karena ini login Google pertama Anda, silakan lengkapi data berikut untuk mendaftar.",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Pilih Role", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "pembeli", child: Text("Pembeli / Customer")),
                        DropdownMenuItem(value: "agen", child: Text("Agen Ikan")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRole = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("No. Handphone", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Masukkan nomor handphone",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Alamat Lengkap", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Masukkan alamat lengkap",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                  child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          if (phoneController.text.isEmpty || addressController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Semua data wajib diisi")),
                            );
                            return;
                          }

                          setDialogState(() {
                            isDialogLoading = true;
                          });

                          final regResponse = await AuthService.registerGoogle(
                            email: email,
                            namaLengkap: defaultName,
                            noTelp: phoneController.text,
                            role: selectedRole,
                            alamat: addressController.text,
                          );

                          setDialogState(() {
                            isDialogLoading = false;
                          });

                          if (regResponse["success"] == true) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString("id_user", regResponse["data"]["id_user"].toString());
                            if (regResponse["data"]["id_agen"] != null) {
                              await prefs.setString("id_agen", regResponse["data"]["id_agen"].toString());
                            }
                            await prefs.setString("nama", regResponse["data"]["nama"] ?? defaultName);
                            await prefs.setString("nama_lengkap", regResponse["data"]["nama"] ?? defaultName);
                            await prefs.setString("username", regResponse["data"]["username"] ?? email);
                            await prefs.setString("no_hp", regResponse["data"]["no_hp"] ?? "");
                            await prefs.setString("alamat", regResponse["data"]["alamat"] ?? "");
                            
                            await prefs.setString("role", selectedRole);
                            await prefs.setBool("isLogin", true);

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            if (selectedRole == "agen") {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardAgen()));
                            } else {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PembeliMainPage()));
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Registrasi Gagal: ${regResponse["message"]}")),
                              );
                            }
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Daftar & Masuk", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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

                const SizedBox(height: 20),

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

                          color: Colors.black.withOpacity(.12),

                          blurRadius: 20,

                          offset: const Offset(0,8),

                        ),

                      ],

                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        "${Api.baseUrl}/logo.png",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.set_meal,
                          color: Colors.blue,
                          size: 58,
                        ),
                      ),
                    ),
                  ),

                ),

                const SizedBox(height: 25),

                Text(

                  "Fresh Fish",

                  style: GoogleFonts.poppins(

                    fontSize: 30,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,

                  ),

                ),

                const SizedBox(height: 6),

                Text(

                  "Penjualan ikan Segar Secara Online",

                  style: GoogleFonts.poppins(

                    color: Colors.white70,

                    fontSize: 14,

                  ),

                ),

                const SizedBox(height: 40),

                //----------------------------------
                // CARD LOGIN
                //----------------------------------

                Container(

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:

                    BorderRadius.circular(28),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withOpacity(.08),

                        blurRadius: 20,

                        offset: const Offset(0,8),

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
                        controller: usernameController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 18,
                          ),
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
                        controller: passwordController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 18,
                          ),
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
                      // LOGIN BUTTON
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

                            borderRadius:
                                BorderRadius.circular(18),

                            boxShadow: [

                              BoxShadow(

                                color:
                                    Colors.blue.withOpacity(.35),

                                blurRadius: 15,

                                offset:
                                    const Offset(0, 6),

                              ),

                            ],

                          ),

                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(

                              backgroundColor:
                                  Colors.transparent,

                              shadowColor:
                                  Colors.transparent,

                              shape:
                                  RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius.circular(18),

                              ),

                            ),

                            onPressed:
                                isLoading ? null : login,

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

                                    "LOGIN",

                                    style:
                                        GoogleFonts.poppins(

                                      color: Colors.white,

                                      fontWeight:
                                          FontWeight.bold,

                                      fontSize: 16,

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

                              thickness: 1,

                            ),

                          ),

                          Padding(

                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),

                            child: Text(

                              "ATAU",

                              style: GoogleFonts.poppins(

                                color: Colors.grey,

                                fontWeight: FontWeight.w500,

                              ),

                            ),

                          ),

                          Expanded(

                            child: Divider(

                              color: Colors.grey.shade300,

                              thickness: 1,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 25),

                      //----------------------------------
                      // GOOGLE LOGIN BUTTON
                      //----------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xffEBF2FF), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: isLoading ? null : loginWithGoogle,
                          icon: Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png",
                            height: 22,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                          ),
                          label: Text(
                            "Masuk dengan Google",
                            style: GoogleFonts.poppins(
                              color: const Color(0xff2C3E50),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      //----------------------------------
                      // REGISTER
                      //----------------------------------

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Text(

                            "Belum memiliki akun?",

                            style: GoogleFonts.poppins(

                              color: Colors.grey.shade700,

                            ),

                          ),

                          TextButton(

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      const RegisterPage(),

                                ),

                              );

                            },

                            child: Text(

                              "Daftar",

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