import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IlaclamaFormScreen extends StatefulWidget {
  final String? onTanimliAlanId; 
  const IlaclamaFormScreen({super.key, this.onTanimliAlanId});

  @override
  // ignore: library_private_types_in_public_api
  _IlaclamaFormScreenState createState() => _IlaclamaFormScreenState();
}

class _IlaclamaFormScreenState extends State<IlaclamaFormScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final _supabase = Supabase.instance.client;

  String? _seciliAlanId;
  String? _seciliIlacId;
  final TextEditingController _miktarController = TextEditingController();
  bool _isLoading = false; 

  List<dynamic> _alanlar = [];
  List<dynamic> _ilaclar = [];

  @override
  void initState() {
    super.initState();
    _seciliAlanId = widget.onTanimliAlanId; 
    
    _verileriGetir(); 
  }

  Future<void> _verileriGetir() async {
    setState(() => _isLoading = true);
    try {
      final alanData = await _supabase.from('alanlar').select('id, alan_adi');
      final ilacData = await _supabase.from('ilac').select('ilac_id, ilac_adi');
      
      setState(() {
        _alanlar = alanData;
        _ilaclar = ilacData;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler çekilirken hata: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _kayitEkle() async {
    // Form doğrulama (Validation)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final kullaniciId = _supabase.auth.currentUser!.id;

      await _supabase.from('ilaclamalar').insert({
        'alan_id': _seciliAlanId,
        'ilac_id': _seciliIlacId, 
        'kullanici_id': kullaniciId,
        'kullanilan_miktar': double.parse(_miktarController.text), 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlaçlama kaydı başarıyla eklendi!')),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İlaçlama Kaydı')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Uygulama Alanı (Tarla/Sera)'),
                    initialValue: _seciliAlanId,
                    items: _alanlar.map((alan) {
                      return DropdownMenuItem<String>(
                        value: alan['id'].toString(),
                        child: Text(alan['alan_adi']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _seciliAlanId = val),
                    validator: (val) => val == null ? 'Lütfen bir alan seçin' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // İLAÇ SEÇİM MENÜSÜ (Dropdown)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kullanılacak İlaç'),
                    initialValue: _seciliIlacId,
                    items: _ilaclar.map((ilac) {
                      return DropdownMenuItem<String>(
                        value: ilac['ilac_id'].toString(),
                        child: Text(ilac['ilac_adi']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _seciliIlacId = val),
                    validator: (val) => val == null ? 'Lütfen bir ilaç seçin' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _miktarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kullanılan Miktar (ml/gr)'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Miktar boş bırakılamaz';
                      if (double.tryParse(val) == null) return 'Geçerli bir rakam girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // KAYDET BUTONU (Submit)
                  ElevatedButton(
                    onPressed: _kayitEkle,
                    child: const Text('Kaydı Tamamla'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}