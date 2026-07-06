import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IkanCard extends StatelessWidget {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final String namaIkan;
  final String harga;
  final String status;
  final VoidCallback onTap;

  IkanCard({
    super.key,
    required this.namaIkan,
    required this.harga,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Container(
              height: 120,
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius:
                BorderRadius.circular(10),
              ),

              child: const Icon(
                Icons.set_meal,
                size: 50,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              namaIkan,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const SizedBox(height: 5),

            Text(
              "${rupiah.format(
                num.tryParse(harga.toString()) ?? 0,
              )} /Kg",
            ),

            const SizedBox(height: 5),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),

              decoration: BoxDecoration(
                color: status == "ready"
                    ? Colors.green
                    : Colors.orange,

                borderRadius:
                BorderRadius.circular(10),
              ),

              child: Text(
                status.toUpperCase(),

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: onTap,

                child: const Text(
                  "Pesan",
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}