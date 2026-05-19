import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlanEkleScreen extends StatefulWidget {
  const AlanEkleScreen({super.key});

  @override
  State<AlanEkleScreen> createState() => _AlanEkleScreenState();
}

class _AlanEkleScreenState extends State<AlanEkleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Form girdilerini kontrol etmek için Controller yapıları
  final TextEditingController _adiController = TextEditingController();
  final TextEditingController _turuController = TextEditingController();
  final TextEditingController _buyuklukController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();
  
  bool _isLoading = false;

  // Supabase 'alanlar' tablosuna yeni veri ekleme metodu (Insert Operation)
  Future<void> _alanikaydet() async {
    // Form Validation (Form Doğrulama): Boş alan kalmasını engeller
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _supabase.from('alanlar').insert({
        'alan_adi': _adiController.text.trim(),
        'alan_turu': _turuController.text.trim(),
        // Supabase'deki 'numeric' tip için String'i double'a çeviriyoruz:
        'buyukluk_dekar': double.parse(_buyuklukController.text),
        'sehir': _konumController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni alan başarıyla eklendi!')),
        );
        Navigator.pop(context); // Alan eklenince ana ekrana geri dön (Pop)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alan eklenirken hata çıktı: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // Bellek sızıntısını (Memory Leak) önlemek için controller'ları kapatıyoruz
    _adiController.dispose();
    _turuController.dispose();
    _buyuklukController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Tarla/Sera Ekle')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _adiController,
                      decoration: const InputDecoration(labelText: 'Alan Adı (Örn: Kuzey Tarlası)'),
                      validator: (val) => val == null || val.isEmpty ? 'Alan adı boş bırakılamaz' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Alan Türü'),
                      items: const [
                        DropdownMenuItem(value: 'Tarla', child: Text('Tarla')),
                        DropdownMenuItem(value: 'Sera', child: Text('Sera')),
                      ],
                      onChanged: (val) {
                        if (val != null) _turuController.text = val;
                      },
                      validator: (val) => val == null || val.isEmpty ? 'Lütfen bir tür seçin' : null,
                    ),
                    TextFormField(
                      controller: _buyuklukController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Büyüklük (Dekar)'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Büyüklük boş bırakılamaz';
                        if (double.tryParse(val) == null) return 'Geçerli bir sayı girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _konumController,
                      decoration: const InputDecoration(labelText: 'Konum (Şehir/İlçe)'),
                      validator: (val) => val == null || val.isEmpty ? 'Konum boş bırakılamaz' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _alanikaydet,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: const Text('Alanı Kaydet'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}