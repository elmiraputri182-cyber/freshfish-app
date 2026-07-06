import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() =>
      _DataUserPageState();
}

class _DataUserPageState
    extends State<DataUserPage> {

  List dataUser = [];
  List filterData = [];

  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController();

        @override
  void initState() {
    super.initState();

    getUsers();
  }
  Future<void> getUsers() async {

  try {

    final response = await http.get(

      Uri.parse(

        "${Api.baseUrl}/admin/get_users.php",

      ),

    );

    if (response.statusCode == 200) {

      final json = jsonDecode(response.body);

      if (json["success"] == true) {

        setState(() {

          dataUser = json["data"];

          filterData = dataUser;

          isLoading = false;

        });

      }

    } else {

      setState(() {

        isLoading = false;

      });

    }

  } catch (e) {

    setState(() {

      isLoading = false;

    });

  }

}
void cariUser(String keyword) {

  setState(() {

    filterData = dataUser.where((item) {

      return item["nama_lengkap"]

          .toString()

          .toLowerCase()

          .contains(

            keyword.toLowerCase(),

          );

    }).toList();

  });

}
@override
Widget build(BuildContext context) {

  return Scaffold(

    backgroundColor: const Color(0xffF5F8FF),

    appBar: AppBar(

      backgroundColor: Colors.blue,

      elevation: 0,

      centerTitle: true,

      foregroundColor: Colors.white,

      title: Text(

        "Data User",

        style: GoogleFonts.poppins(

          fontWeight: FontWeight.bold,

        ),

      ),

    ),

    body: RefreshIndicator(

  onRefresh: getUsers,

  child: Column(

    children: [

      const SizedBox(height: 18),

      // Search

      Padding(

        padding: const EdgeInsets.symmetric(horizontal: 18),

        child: TextField(

          controller: searchController,

          onChanged: cariUser,

          decoration: InputDecoration(

            hintText: "Cari nama user...",

            prefixIcon: const Icon(

              Icons.search,

              color: Colors.blue,

            ),

            filled: true,

            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(

              vertical: 15,

            ),

            border: OutlineInputBorder(

              borderRadius: BorderRadius.circular(18),

              borderSide: BorderSide.none,

            ),

            enabledBorder: OutlineInputBorder(

              borderRadius: BorderRadius.circular(18),

              borderSide: BorderSide.none,

            ),

            focusedBorder: OutlineInputBorder(

              borderRadius: BorderRadius.circular(18),

              borderSide: const BorderSide(

                color: Colors.blue,

              ),

            ),

          ),

        ),

      ),

      const SizedBox(height: 18),

      Expanded(

        child: isLoading

            ? const Center(

                child: CircularProgressIndicator(),

              )

            : filterData.isEmpty

                ? Center(

                    child: Column(

                      mainAxisAlignment:

                          MainAxisAlignment.center,

                      children: [

                        Icon(

                          Icons.people,

                          size: 90,

                          color: Colors.grey.shade400,

                        ),

                        const SizedBox(height: 15),

                        Text(

                          "Belum Ada Data User",

                          style: GoogleFonts.poppins(

                            fontSize: 18,

                            fontWeight:

                                FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 5),

                        Text(

                          "Data user akan muncul di sini",

                          style: GoogleFonts.poppins(

                            color: Colors.grey,

                          ),

                        ),

                      ],

                    ),

                  )

                : ListView.builder(

                    padding:

                        const EdgeInsets.symmetric(

                      horizontal: 18,

                    ),

                    itemCount: filterData.length,

                    itemBuilder: (context, index) {

                      final user = filterData[index];

                      return buildCardUser(user);

                    },

                  ),

      ),

    ],

  ),

),
    );

  }
  Widget buildCardUser(Map user) {

  return Container(

    margin: const EdgeInsets.only(bottom: 18),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius: BorderRadius.circular(24),

      boxShadow: [

        BoxShadow(

          color: Colors.black.withOpacity(0.05),

          blurRadius: 12,

          offset: const Offset(0, 5),

        ),

      ],

    ),

    child: Padding(

      padding: const EdgeInsets.all(18),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              CircleAvatar(

                radius: 30,

                backgroundColor: Colors.blue.shade100,

                child: Icon(

                  Icons.person,

                  color: Colors.blue,

                  size: 32,

                ),

              ),

              const SizedBox(width: 15),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      user["nama_lengkap"] ?? "-",

                      style: GoogleFonts.poppins(

                        fontSize: 20,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 5),

                    Container(

                      padding: const EdgeInsets.symmetric(

                        horizontal: 12,

                        vertical: 5,

                      ),

                      decoration: BoxDecoration(

                        color: user["role"] == "Admin"

                            ? Colors.red.shade100
                            : user["role"] == "Agen"
                                ? Colors.green.shade100
                                : Colors.orange.shade100,

                        borderRadius: BorderRadius.circular(20),

                      ),

                      child: Text(

                        user["role"] ?? "-",

                        style: GoogleFonts.poppins(

                          fontWeight: FontWeight.w600,

                          color: user["role"] == "Admin"

                              ? Colors.red
                              : user["role"] == "Agen"
                                  ? Colors.green
                                  : Colors.orange,

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

          const SizedBox(height: 20),

          Row(

            children: [

              Expanded(

                child: buildInfoUser(

                  Icons.person_outline,

                  "Username",

                  user["username"] ?? "-",

                ),

              ),

              Expanded(

                child: buildInfoUser(

                  Icons.phone,

                  "No HP",

                  user["no_hp"] ?? "-",

                ),

              ),

            ],

          ),

          const SizedBox(height: 15),

          buildInfoUser(

            Icons.location_on,

            "Alamat",

            user["alamat"] ?? "-",

          ),

        ],

      ),

    ),

  );

}
Widget buildInfoUser(
  IconData icon,
  String title,
  String value,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 20,
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

          ],
        ),
      ),

    ],
  );
}
    }