import 'package:flutter/material.dart';
import 'ilacalama_form_screen.dart';

class AlanDetayScreen extends StatelessWidget {
  final Map<String, dynamic> alan;

  const AlanDetayScreen({super.key, required this.alan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alan['alan_adi'] ?? 'Alan Detayı'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tür: ${alan['alan_turu']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Şehir: ${alan['sehir']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Büyüklük: ${alan['buyukluk_dekar']} Dekar', style: const TextStyle(fontSize: 18)),
            const Divider(height: 32, thickness: 2),
            const Text(
              'İlaçlama Geçmişi', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const Expanded(
              child: Center(child: Text('Henüz bu alana ilaç atılmadı.')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => IlaclamaFormScreen(onTanimliAlanId: alan['id'].toString()),
    ),
  );
},
        backgroundColor: Colors.green,
        child: const Icon(Icons.water_drop, color: Colors.white),
      ),
    );
  }
}