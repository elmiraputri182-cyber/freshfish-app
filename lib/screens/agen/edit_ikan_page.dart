import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditIkanPage extends StatefulWidget {
  final dynamic ikan;
  final VoidCallback onSuccess;

  const EditIkanPage({super.key, required this.ikan, required this.onSuccess});

  @override
  State<EditIkanPage> createState() => _EditIkanPageState();
}

class _EditIkanPageState extends State<EditIkanPage> {
  File? imageFile;
  late TextEditingController nama;
  late TextEditingController jumlah;
  late TextEditingController harga;

  String kategori = "Ikan Laut";
  bool isLoading = false;
  List listMasterIkan = [];
  String? selectedNamaIkan;

  @override
  void initState() {
    super.initState();
    nama = TextEditingController(text: widget.ikan["nama_ikan"]);
    jumlah = TextEditingController(text: widget.ikan["jumlah"]);
    harga = TextEditingController(text: widget.ikan["harga"]);
    kategori = widget.ikan["kategori"] ?? "Ikan Laut";
    selectedNamaIkan = widget.ikan["nama_ikan"];
    fetchMasterIkan();
  }

  Future<void> fetchMasterIkan() async {
    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/admin/get_master_ikan.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            listMasterIkan = data["data"] ?? [];
            final exists = listMasterIkan.any((item) => item["nama_ikan"] == selectedNamaIkan);
            if (!exists && selectedNamaIkan != null) {
              listMasterIkan.add({
                "id_master": 0,
                "nama_ikan": selectedNamaIkan
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    nama.dispose();
    jumlah.dispose();
    harga.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitEdit() async {
    if (nama.text.isEmpty || jumlah.text.isEmpty || harga.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field harus diisi"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${Api.baseUrl}/update_ikan.php"),
      );

      request.fields["id_ikan"] = widget.ikan["id_ikan"].toString();
      request.fields["nama_ikan"] = nama.text;
      request.fields["kategori"] = kategori;
      request.fields["jumlah"] = jumlah.text;
      request.fields["harga"] = harga.text;
      request.fields["status_tersedia"] = widget.ikan["status_tersedia"]
          .toString();

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("foto_ikan", imageFile!.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (!mounted) return;

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );

        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Gagal mengupdate data"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2C3E50)),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0060A9), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        "Edit Data Ikan",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
          fontSize: 18,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // FOTO PICKER
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.network(imageFile!.path, fit: BoxFit.cover)
                            : Image.file(imageFile!, fit: BoxFit.cover),
                      )
                    : widget.ikan["foto_ikan"] != null &&
                          widget.ikan["foto_ikan"] != ""
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          "${Api.baseUrl}/uploads/${widget.ikan["foto_ikan"]}",
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Ubah Foto Ikan",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: selectedNamaIkan,
                  isExpanded: true,
                  hint: Text(
                    "Pilih Nama Ikan",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2C3E50), fontWeight: FontWeight.bold),
                  items: listMasterIkan.map<DropdownMenuItem<String>>((item) {
                    final n = item["nama_ikan"].toString();
                    return DropdownMenuItem<String>(
                      value: n,
                      child: Text(n),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNamaIkan = value;
                      nama.text = value ?? "";
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: kategori,
                  isExpanded: true,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Ikan Laut",
                      child: Text("Ikan Laut"),
                    ),
                    DropdownMenuItem(
                      value: "Ikan Tawar",
                      child: Text("Ikan Tawar"),
                    ),
                    DropdownMenuItem(value: "Udang", child: Text("Udang")),
                    DropdownMenuItem(value: "Kerang", child: Text("Kerang")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        kategori = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(jumlah, "Jumlah (Kg)"),
            const SizedBox(height: 12),
            _buildField(harga, "Harga (Rp)"),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2C3E50),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Batal",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0060A9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isLoading ? null : _submitEdit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Simpan",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
