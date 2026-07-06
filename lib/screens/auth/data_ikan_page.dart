import 'package:flutter/material.dart';

class DataIkanPage extends StatelessWidget {
  const DataIkanPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Ikan"),
      ),

      body: ListView(

        children: const [

          ListTile(
            title: Text("Ikan Kerapu"),
            subtitle: Text("Rp 75.000"),
          ),

          ListTile(
            title: Text("Ikan Tongkol"),
            subtitle: Text("Rp 25.000"),
          ),

        ],
      ),
    );
  }
}