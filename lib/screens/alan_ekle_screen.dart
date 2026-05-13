import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlanEkleScreen extends StatefulWidget {
  const AlanEkleScreen({super.key});

  @override
  State<AlanEkleScreen> createState() => _AlanEkleScreenState();
}

class _AlanEkleScreenState extends State<AlanEkleScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _alanAdiController = TextEditingController();
  final _sehirController = TextEditingController();
  final _buyuklukController = TextEditingController();
  
  String _secilenAlanTuru = 'Tarla';
  bool _isLoading = false;

  Future<void> _alanKaydet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _supabase.from('alanlar').insert({
        'alan_adi': _alanAdiController.text.trim(),
        'alan_turu': _secilenAlanTuru,
        'sehir': _sehirController.text.trim(),
        'buyukluk_dekar': double.parse(_buyuklukController.text.trim()),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alan başarıyla eklendi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // true: "Veri eklendi, listeyi yenile" demek
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Alan Ekle'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _alanAdiController,
                decoration: const InputDecoration(
                  labelText: 'Alan Adı (Örn: Kuzey Tarlası)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _secilenAlanTuru,
                decoration: const InputDecoration(
                  labelText: 'Alan Türü',
                  border: OutlineInputBorder(),
                ),
                items: ['Tarla', 'Sera'].map((tur) {
                  return DropdownMenuItem(value: tur, child: Text(tur));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _secilenAlanTuru = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _sehirController,
                decoration: const InputDecoration(
                  labelText: 'Şehir (Örn: Konya)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _buyuklukController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Büyüklük (Dekar)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Boş bırakılamaz';
                  if (double.tryParse(val) == null) return 'Geçerli bir sayı girin';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _alanKaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KAYDET', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alanAdiController.dispose();
    _sehirController.dispose();
    _buyuklukController.dispose();
    super.dispose();
  }
}