import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahIkanPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const TambahIkanPage({super.key, required this.onSuccess});

  @override
  State<TambahIkanPage> createState() => _TambahIkanPageState();
}

class _TambahIkanPageState extends State<TambahIkanPage> {
  File? imageFile;
  final namaController = TextEditingController();

  final jumlahController = TextEditingController();

  final hargaController = TextEditingController();

  String status = "ready";
  String kategori = "Ikan Laut";

  double? latitude;
  double? longitude;
  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    jumlahController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Layanan lokasi tidak diaktifkan")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi berhasil diambil")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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

  Future<void> tambahIkan() async {
    if (namaController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        hargaController.text.isEmpty ||
        imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final pref = await SharedPreferences.getInstance();
      final idUser = pref.getString("id_user") ?? "";

      var request = http.MultipartRequest(
        "POST",

        Uri.parse(
          "${Api.baseUrl}/tambah_ikan.php",
        ),
      );

      request.fields["id_agen"] = idUser;

      request.fields["nama_ikan"] = namaController.text;

      request.fields["jumlah"] = jumlahController.text;

      request.fields["harga"] = hargaController.text;

      request.fields["status_tersedia"] = status;

      request.fields["kategori"] = kategori;

      request.fields["latitude"] = latitude?.toString() ?? "0";

      request.fields["longitude"] = longitude?.toString() ?? "0";

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("foto_ikan", imageFile!.path),
        );
      }

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      print("RESPONSE EDIT = ");
      print(responseData);

      final data = jsonDecode(responseData);

      if (!mounted) return;

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ikan berhasil ditambahkan")),
        );

        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Gagal menambahkan ikan")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error : $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          "Tambah Ikan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [
            // FOTO
            Text(
              "Foto Ikan",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF5F8FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffD0E1FD), width: 1.5),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: kIsWeb
                            ? Image.network(imageFile!.path, fit: BoxFit.cover)
                            : Image.file(imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(Icons.camera_alt_rounded, size: 30, color: Colors.blue),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Tap untuk pilih foto",
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Format: JPG, PNG (Maks 5MB)",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            buildField(
              namaController,
              "Nama Ikan",
              Icons.set_meal,
            ),

            const SizedBox(height: 20),

            Align(

              alignment: Alignment.centerLeft,

              child: Text(

                "Kategori",

                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.01),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffEBF2FF), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: kategori,
                  isExpanded: true,
                  style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                  items: const [
                    DropdownMenuItem(
                      value: "Ikan Laut",
                      child: Text("Ikan Laut"),
                    ),
                    DropdownMenuItem(
                      value: "Ikan Tawar",
                      child: Text("Ikan Tawar"),
                    ),
                    DropdownMenuItem(
                      value: "Udang",
                      child: Text("Udang"),
                    ),
                    DropdownMenuItem(
                      value: "Kerang",
                      child: Text("Kerang"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      kategori = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildField(
              jumlahController,
              "Jumlah",
              Icons.scale,
              suffix: "KG",
              isNumber: true,
            ),

            const SizedBox(height: 20),

            buildField(
              hargaController,
              "Harga",
              Icons.attach_money,
              prefix: "Rp ",
              isNumber: true,
            ),
            
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.01),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffEBF2FF), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: status,
                  isExpanded: true,
                  style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                  items: const [
                    DropdownMenuItem(value: "ready", child: Text("Ready")),
                    DropdownMenuItem(value: "pre_order", child: Text("Pre Order")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: getLocation,

                icon: const Icon(Icons.location_on, color: Colors.white),

                label: Text(
                  latitude == null ? "AMBIL LOKASI" : "Lokasi berhasil diambil",

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (latitude != null) const SizedBox(height: 15),

            if (latitude != null)
              Container(
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(
                  children: [
                    const Text("Lokasi berhasil diambil"),

                    Text("Latitude : $latitude"),

                    Text("Longitude : $longitude"),
                  ],
                ),
              ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: isLoading
                    ? null
                    : () {
                        tambahIkan();
                      },

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
                        "SIMPAN",

                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    String? suffix,
    String? prefix,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        prefixText: prefix,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.blue.withOpacity(0.01),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xffEBF2FF), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xffEBF2FF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
    );
  }
}
