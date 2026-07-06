import 'package:appfreshfish/config/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../services/pesanan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF0060A9); // deep ocean blue
const _kAccent = Color(0xFF2196F3); // bright aqua
const _kSurface = Color(0xFFF8FAFC); // pale sky
const _kCardBg = Colors.white;
const _kOrange = Color(0xFF0060A9); // vibrant order CTA
const _kTextDark = Color(0xFF2C3E50);
const _kTextLight = Color(0xFF64748B);
const _kDivider = Color(0xFFE2E8F0);
const _kRadius = 20.0;

class OrderSekarangPage extends StatefulWidget {
  final Map ikan;

  const OrderSekarangPage({super.key, required this.ikan});

  @override
  State<OrderSekarangPage> createState() => _OrderSekarangPageState();
}

class _OrderSekarangPageState extends State<OrderSekarangPage> {
  final TextEditingController jumlahKg = TextEditingController();

  String metodePengambilan = "cod";
  String metodePembayaran = "cod";

  double total = 0;
  bool isLoading = false;

  void hitungTotal() {
    final harga = double.tryParse(widget.ikan["harga"].toString()) ?? 0;
    final kg = double.tryParse(jumlahKg.text) ?? 0;
    setState(() => total = harga * kg);
  }

  // ── Reusable section label ────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _kTextLight,
        letterSpacing: 0.6,
      ),
    ),
  );

  // ── Styled card wrapper ───────────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(_kRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.015),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );

  // ── Delivery option tile ──────────────────────────────────────────────────
  Widget _deliveryOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = metodePengambilan == value;
    return GestureDetector(
      onTap: () => setState(() => metodePengambilan = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _kPrimary.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kPrimary : _kDivider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? _kPrimary : _kSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : _kTextLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? _kPrimary : _kTextDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _kTextLight,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: _kPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final harga = double.tryParse(widget.ikan["harga"].toString()) ?? 0;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kTextDark,
        title: Text(
          "Buat Pesanan",
          style: GoogleFonts.poppins(
            color: _kTextDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero foto ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  "${Api.baseUrl}/uploads/${widget.ikan["foto_ikan"]}",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: _kDivider,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: _kTextLight,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Info ikan ─────────────────────────────────────────────────
            _card(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ikan["nama_ikan"] ?? "-",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _kTextDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ikan segar langsung dari nelayan",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _kTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(harga),
                        style: GoogleFonts.poppins(
                          color: _kPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "per kilogram",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _kTextLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Jumlah pesanan ────────────────────────────────────────────
            _sectionLabel("JUMLAH PESANAN"),
            _card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: jumlahKg,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _kTextDark,
                ),
                onChanged: (_) => hitungTotal(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Masukkan berat (kg)",
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _kTextLight,
                  ),
                  prefixIcon: const Icon(Icons.scale_outlined, color: _kAccent),
                  suffixText: "KG",
                  suffixStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: _kPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Metode pengambilan ────────────────────────────────────────
            _sectionLabel("METODE PENGAMBILAN"),
            _card(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _deliveryOption(
                    value: "cod",
                    icon: Icons.delivery_dining_rounded,
                    title: "Antar ke Lokasi (COD)",
                    subtitle: "Kami antar ke alamat Anda",
                  ),
                  const SizedBox(height: 8),
                  _deliveryOption(
                    value: "ambil",
                    icon: Icons.storefront_rounded,
                    title: "Ambil di Tempat",
                    subtitle: "Datang langsung ke kios agen",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Metode pembayaran ─────────────────────────────────────────
            _sectionLabel("METODE PEMBAYARAN"),
            _card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: DropdownButtonFormField<String>(
                value: metodePembayaran,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _kPrimary,
                ),
                style: GoogleFonts.poppins(
                  color: _kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.payment_rounded, color: _kAccent),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "cod",
                    child: Text("Bayar di Tempat (COD)"),
                  ),
                  DropdownMenuItem(value: "cash", child: Text("Tunai / Cash")),
                  DropdownMenuItem(
                    value: "dana",
                    child: Text("Transfer Bank / E-Wallet"),
                  ),
                ],
                onChanged: (value) => setState(() => metodePembayaran = value!),
              ),
            ),
            const SizedBox(height: 24),

            // ── Ringkasan harga ───────────────────────────────────────────
            _sectionLabel("RINGKASAN HARGA"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kPrimary, _kAccent],
                ),
                borderRadius: BorderRadius.circular(_kRadius),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Harga / kg",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(harga),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jumlah",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        jumlahKg.text.isEmpty ? "0 kg" : "${jumlahKg.text} kg",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: Colors.white.withOpacity(0.25),
                      thickness: 1,
                    ),
                  ),
                  Text(
                    "TOTAL PEMBAYARAN",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(total),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: isLoading
                ? null
                : () async {
                    if (jumlahKg.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Masukkan jumlah kg terlebih dahulu",
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() => isLoading = true);

                    final prefs = await SharedPreferences.getInstance();
                    final idUser = prefs.getString("id_user") ?? "";

                    final sukses = await PesananService.tambahPesanan(
                      idPembeli: idUser,
                      idAgen: widget.ikan["id_agen"].toString(),
                      idIkan: widget.ikan["id_ikan"].toString(),
                      jumlahKg: jumlahKg.text,
                      metodePengambilan: metodePengambilan,
                      metodePembayaran: metodePembayaran,
                      totalBayar: total.toString(),
                    );

                    setState(() => isLoading = false);

                    if (sukses) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pesanan berhasil dibuat!",
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF2EC86A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pesanan gagal, coba lagi",
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Pesan Sekarang",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
