import 'package:appfreshfish/config/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MasterIkanPage extends StatefulWidget {
  const MasterIkanPage({super.key});

  @override
  State<MasterIkanPage> createState() => _MasterIkanPageState();
}

class _MasterIkanPageState extends State<MasterIkanPage> {
  List listIkan = [];
  List filteredIkan = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchIkan();
  }

  Future<void> fetchIkan() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/admin/get_master_ikan.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            listIkan = data["data"] ?? [];
            filteredIkan = listIkan;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredIkan = listIkan
          .where((item) =>
              item["nama_ikan"].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> tambahIkan(String nama, String kategori) async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/admin/tambah_master_ikan.php"),
        body: {"nama_ikan": nama, "kategori": kategori},
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Berhasil menambah nama ikan"),
            backgroundColor: Colors.green,
          ),
        );
        fetchIkan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Gagal menambahkan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> editIkan(int id, String nama, String kategori) async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/admin/edit_master_ikan.php"),
        body: {"id_master": id.toString(), "nama_ikan": nama, "kategori": kategori},
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Berhasil memperbarui"),
            backgroundColor: Colors.green,
          ),
        );
        fetchIkan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Gagal memperbarui"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> hapusIkan(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/admin/hapus_master_ikan.php"),
        body: {"id_master": id.toString()},
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Berhasil menghapus"),
            backgroundColor: Colors.green,
          ),
        );
        fetchIkan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Gagal menghapus"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showFormDialog({int? id, String? currentName, String? currentKategori}) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: currentName ?? "");
    String selectedKategori = currentKategori ?? "Ikan Laut";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                id == null ? "Tambah Master Ikan" : "Edit Nama Ikan",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "Nama Ikan",
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Nama ikan tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Ikan Laut", child: Text("Ikan Laut")),
                        DropdownMenuItem(value: "Ikan Tawar", child: Text("Ikan Tawar")),
                        DropdownMenuItem(value: "Udang", child: Text("Udang")),
                        DropdownMenuItem(value: "Kerang", child: Text("Kerang")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedKategori = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0060A9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      if (id == null) {
                        tambahIkan(controller.text.trim(), selectedKategori);
                      } else {
                        editIkan(id, controller.text.trim(), selectedKategori);
                      }
                    }
                  },
                  child: Text(
                    "Simpan",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showConfirmDeleteDialog(int id, String nama) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Hapus Nama Ikan?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus '$nama' dari daftar master? Agen tidak akan bisa memilih ikan ini lagi.",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                hapusIkan(id);
              },
              child: Text(
                "Hapus",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        centerTitle: true,
        title: Text(
          "Kelola Master Ikan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Cari nama ikan...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Main list or loading
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0060A9)),
                  )
                : filteredIkan.isEmpty
                    ? Center(
                        child: Text(
                          "Tidak ada nama ikan ditemukan",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchIkan,
                        color: const Color(0xFF0060A9),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredIkan.length,
                          itemBuilder: (context, index) {
                            final item = filteredIkan[index];
                            final id = item["id_master"] as int;
                            final nama = item["nama_ikan"] as String;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.01),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFEBF5FF),
                                    radius: 18,
                                    child: const Icon(
                                      Icons.set_meal_outlined,
                                      color: Color(0xFF0060A9),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: const Color(0xFF2C3E50),
                                          ),
                                        ),
                                        Text(
                                          item["kategori"]?.toString() ?? "Ikan Laut",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => showFormDialog(
                                      id: id,
                                      currentName: nama,
                                      currentKategori: item["kategori"]?.toString(),
                                    ),
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                  ),
                                  IconButton(
                                    onPressed: () => showConfirmDeleteDialog(id, nama),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0060A9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
