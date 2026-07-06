import 'package:appfreshfish/config/api.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormIkanPage extends StatefulWidget {

  final Map<String, dynamic>? ikan;

  const FormIkanPage({

    super.key,

    this.ikan,

  });

  @override
  State<FormIkanPage> createState() => _FormIkanPageState();

}

class _FormIkanPageState extends State<FormIkanPage> {

  bool get isEdit => widget.ikan != null;

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();

  String kategori = "Ikan Laut";
  String status = "ready";

  String? fotoLama;

  File? image;

  List agenList = [];

  String? selectedAgen;

  Map<String, dynamic>? agenTerpilih;

  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void dispose() {

    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();

    super.dispose();

  }

  Future<void> pilihGambar() async {

    final XFile? pickedFile = await picker.pickImage(

      source: ImageSource.gallery,

      imageQuality: 80,

    );

    if (pickedFile != null) {

      setState(() {

        image = File(pickedFile.path);

      });

    }

  }
  Future<void> getAgen() async {

  try {

    final response = await http.get(
      Uri.parse(
        "${Api.baseUrl}/admin/get_agen_dropdown.php",
      ),
    );

    if (response.statusCode == 200) {

      final json = jsonDecode(response.body);

      if (json["success"] == true) {

        setState(() {

          agenList = json["data"];

        });

        if (isEdit && selectedAgen != null) {

          try {

            agenTerpilih = agenList.firstWhere(

              (e) => e["id_user"].toString() == selectedAgen,

            );

          } catch (e) {

            agenTerpilih = null;

          }

        }

      }

    }

  } catch (e) {

    debugPrint(e.toString());

  }

}

  @override
  void initState() {

    super.initState();

    if (isEdit) {
      isiData();
    }

    getAgen();

  }
  void isiData(){
  
  print(widget.ikan);

  namaController.text =
      widget.ikan!["nama_ikan"];

  hargaController.text =
      widget.ikan!["harga"].toString();

  stokController.text =
      widget.ikan!["jumlah"].toString();

  kategori =
      widget.ikan!["kategori"];

  status =
      widget.ikan!["status_tersedia"];

  selectedAgen =
      widget.ikan!["id_agen"].toString();

}
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF5F8FF),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.blue,

        foregroundColor: Colors.white,

        title: Text(

          isEdit

              ? "Edit Ikan"

              : "Tambah Ikan",

          style: GoogleFonts.poppins(

            fontWeight: FontWeight.bold,

          ),

        ),

      ),
      

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    isEdit
                        ? "Edit Data Ikan"
                        : "Tambah Data Ikan",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isEdit
                        ? "Perbarui informasi ikan yang tersedia."
                        : "Lengkapi data ikan sebelum disimpan.",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                    ),
                  ),

                ],
              ),
            ),
            
            const SizedBox(height: 20),

            Card(
              elevation: 5,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    buildImagePicker(),

                    const SizedBox(height: 25),

                    buildTextField(
                      controller: namaController,
                      label: "Nama Ikan",
                      icon: Icons.set_meal,
                    ),

                    const SizedBox(height: 18),

                    buildTextField(
                      controller: hargaController,
                      label: "Harga",
                      icon: Icons.payments,
                      keyboard: TextInputType.number,
                    ),

                    const SizedBox(height: 18),

                    buildTextField(
                      controller: stokController,
                      label: "Stok (Kg)",
                      icon: Icons.inventory,
                      keyboard: TextInputType.number,
                    ),

                    const SizedBox(height: 18),

                    buildKategori(),

                    const SizedBox(height: 18),

                    buildStatus(),

                    const SizedBox(height: 18),

                    buildDropdownAgen(),

                    if (agenTerpilih != null) ...[
                      const SizedBox(height: 18),
                      buildInfoAgen(),
                    ],

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1565C0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isEdit) {
                                  updateIkan();
                                } else {
                                  simpanIkan();
                                }
                              },
                        icon: Icon(
                          isEdit ? Icons.edit : Icons.save,
                          color: Colors.white,
                        ),
                        label: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? "Update Data" : "Simpan Data",
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
            ),

          ],

        ),

      ),

    );

  }

Widget buildImagePicker() {

  return GestureDetector(

    onTap: pilihGambar,

    child: AnimatedContainer(

      duration: const Duration(milliseconds: 300),

      height: 230,

      width: double.infinity,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(

          color: Colors.blue.shade100,

          width: 1.5,

        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(.05),

            blurRadius: 12,

            offset: const Offset(0,6),

          )

        ],

      ),

      child: image == null

          ? Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                CircleAvatar(

                  radius: 35,

                  backgroundColor: Colors.blue.shade50,

                  child: const Icon(

                    Icons.add_photo_alternate_rounded,

                    size: 38,

                    color: Color(0xff1565C0),

                  ),

                ),

                const SizedBox(height: 18),

                Text(

                  "Tambah Foto Ikan",

                  style: GoogleFonts.poppins(

                    fontWeight: FontWeight.bold,

                    fontSize: 18,

                  ),

                ),

                const SizedBox(height: 6),

                Text(

                  "Tap untuk memilih gambar",

                  style: GoogleFonts.poppins(

                    color: Colors.grey,

                    fontSize: 13,

                  ),

                ),

              ],

            )

          : Stack(

              children: [

                ClipRRect(

                  borderRadius: BorderRadius.circular(24),

                  child: Image.file(

                    image!,

                    width: double.infinity,

                    height: 230,

                    fit: BoxFit.cover,

                  ),

                ),

                Positioned(

                  right: 15,

                  top: 15,

                  child: CircleAvatar(

                    radius: 22,

                    backgroundColor: Colors.white,

                    child: IconButton(

                      onPressed: pilihGambar,

                      icon: const Icon(

                        Icons.camera_alt,

                        color: Color(0xff1565C0),

                      ),

                    ),

                  ),

                ),

              ],

            ),

    ),

  );

}

Future<void> simpanIkan() async {

  if (namaController.text.isEmpty ||
    hargaController.text.isEmpty ||
    stokController.text.isEmpty ||
    selectedAgen == null ||
    image == null) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text("Semua data harus diisi"),

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

      Uri.parse(

        "${Api.baseUrl}/admin/tambah_ikan.php",

      ),

    );

    request.fields["nama_ikan"] = namaController.text;

    request.fields["harga"] = hargaController.text;

    request.fields["jumlah"] = stokController.text;

    request.fields["kategori"] = kategori;

    request.fields["status_tersedia"] = status;

    request.fields["id_agen"] = selectedAgen ?? "";

    request.files.add(

      await http.MultipartFile.fromPath(

        "foto_ikan",

        image!.path,

      ),

    );

    final response = await request.send();

    final hasil = await response.stream.bytesToString();

    final json = jsonDecode(hasil);

    setState(() {

      isLoading = false;

    });

    if (json["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Data ikan berhasil ditambahkan"),

        ),

      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(json["message"]),

        ),

      );

    }

  } catch (e) {

    setState(() {

      isLoading = false;

    });

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(e.toString()),

      ),

    );

  }

}
Future<void> updateIkan() async {

  if (namaController.text.isEmpty ||
      hargaController.text.isEmpty ||
      stokController.text.isEmpty ||
      selectedAgen == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lengkapi semua data."),
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

      Uri.parse(
        "${Api.baseUrl}/admin/edit_ikan.php",
      ),

    );

    request.fields["id_ikan"] =
        widget.ikan!["id_ikan"].toString();

    request.fields["nama_ikan"] =
        namaController.text;

    request.fields["harga"] =
        hargaController.text;

    request.fields["jumlah"] =
        stokController.text;

    request.fields["kategori"] =
        kategori;

    request.fields["status_tersedia"] =
        status;

    request.fields["id_agen"] =
        selectedAgen!;

    // Upload foto baru jika dipilih
    if(image != null){

      request.files.add(

        await http.MultipartFile.fromPath(

          "foto_ikan",

          image!.path,

        ),

      );

    }

    final response = await request.send();

    final hasil =
        await response.stream.bytesToString();

    final json = jsonDecode(hasil);

    setState(() {

      isLoading = false;

    });

    if(json["success"]){

      Navigator.pop(context,true);

    }else{

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(json["message"]),

        ),

      );

    }

  } catch(e){

    setState(() {

      isLoading = false;

    });

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(e.toString()),

      ),

    );

  }

}
Widget buildTextField({

  required TextEditingController controller,

  required String label,

  required IconData icon,

  TextInputType keyboard = TextInputType.text,

}) {

  return TextField(

    controller: controller,

    keyboardType: keyboard,

    decoration: InputDecoration(

      labelText: label,

      prefixIcon: Icon(
        icon,
        color: const Color(0xff1565C0),
      ),

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(16),

        borderSide: const BorderSide(
          color: Color(0xff1565C0),
          width: 2,
        ),

      ),

    ),

  );

}
Widget buildKategori() {

  return DropdownButtonFormField<String>(

    value: kategori,

    icon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Color(0xff1565C0),
    ),

    decoration: InputDecoration(

      labelText: "Kategori",

      prefixIcon: const Icon(
        Icons.category,
        color: Color(0xff1565C0),
      ),

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(16),

        borderSide: const BorderSide(
          color: Color(0xff1565C0),
          width: 2,
        ),

      ),

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

      DropdownMenuItem(
        value: "Udang",
        child: Text("Udang"),
      ),

      DropdownMenuItem(
        value: "Kerang",
        child: Text("Kerang"),
      ),

    ],

    onChanged: (v) {

      setState(() {

        kategori = v!;

      });

    },

  );

}
Widget buildStatus() {

  return DropdownButtonFormField<String>(

    value: status,

    decoration: InputDecoration(
      labelText: "Status",
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    items: const [

      DropdownMenuItem(
        value: "ready",
        child: Text("Ready"),
      ),

      DropdownMenuItem(
        value: "pre_order",
        child: Text("Pre Order"),
      ),

    ],

    onChanged: (v){

      setState(() {

        status = v!;

      });

    },

  );

}

Widget buildDropdownAgen() {

  return DropdownButtonFormField<String>(

    value: agenList.any(
      (e) => e["id_user"].toString() == selectedAgen,
    )
        ? selectedAgen
        : null,

    icon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Color(0xff1565C0),
    ),

    decoration: InputDecoration(

      labelText: "Pilih Agen",

      prefixIcon: const Icon(
        Icons.person,
        color: Color(0xff1565C0),
      ),

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xff1565C0),
          width: 2,
        ),
      ),

    ),

    items: agenList.map<DropdownMenuItem<String>>((item) {

      return DropdownMenuItem(

        value: item["id_user"].toString(),

        child: Text(
          item["nama_lengkap"],
          style: GoogleFonts.poppins(),
        ),

      );

    }).toList(),

    onChanged: (value) {

      setState(() {

        selectedAgen = value;

        try {

          agenTerpilih = agenList.firstWhere(
            (e) => e["id_user"].toString() == value,
          );

        } catch (_) {

          agenTerpilih = null;

        }

      });

    },

  );

}
Widget buildInfoAgen() {

  return Container(

    margin: const EdgeInsets.only(top: 18),

    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(

      color: Colors.blue.shade50,

      borderRadius: BorderRadius.circular(18),

      border: Border.all(
        color: Colors.blue.shade100,
      ),

    ),

    child: Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        CircleAvatar(

          radius: 28,

          backgroundColor: Colors.blue.shade100,

          child: const Icon(
            Icons.person,
            color: Color(0xff1565C0),
            size: 30,
          ),

        ),

        const SizedBox(width: 15),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                agenTerpilih!["nama_lengkap"],

                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

              ),

              const SizedBox(height: 12),

              Row(

                children: [

                  const Icon(
                    Icons.phone,
                    color: Colors.green,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(

                    child: Text(
                      agenTerpilih!["no_telp"],
                      style: GoogleFonts.poppins(),
                    ),

                  ),

                ],

              ),

              const SizedBox(height: 10),

              Row(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(

                    child: Text(
                      agenTerpilih!["alamat"],
                      style: GoogleFonts.poppins(),
                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

      ],

    ),

  );

}
}