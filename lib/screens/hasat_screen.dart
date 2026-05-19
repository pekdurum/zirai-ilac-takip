import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HasatEkleScreen extends StatefulWidget {
  final String alanId;
  final String alanAdi;

  const HasatEkleScreen({super.key, required this.alanId, required this.alanAdi});

  @override
  State<HasatEkleScreen> createState() => _HasatEkleScreenState();
}

class _HasatEkleScreenState extends State<HasatEkleScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  bool _hasatGuvenliMi = true; 
  String _uyariMesaji = "Hasat durumu hesaplanıyor...";
  
  final TextEditingController _miktarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _guvenlikKontroluYap(); 
  }

  Future<void> _guvenlikKontroluYap() async {
    try {
      final sonIlaclama = await _supabase
          .from('ilaclamalar')
          .select('uygulama_tarihi, ilac(ilac_adi, bekleme_suresi_gun)')
          .eq('alan_id', widget.alanId)
          .order('uygulama_tarihi', ascending: false)
          .limit(1);

      if (sonIlaclama.isEmpty) {
        setState(() {
          _hasatGuvenliMi = true;
          _uyariMesaji = "Bu alanda kimyasal ilaç kaydı bulunmuyor. Hasat GÜVENLİ! 🌿";
          _isLoading = false;
        });
        return;
      }

      final kayit = sonIlaclama.first;
      final uygulamaTarihi = DateTime.parse(kayit['uygulama_tarihi'].toString());
      final beklemeSuresi = kayit['ilac'] != null ? (kayit['ilac']['bekleme_suresi_gun'] ?? 0) : 0;
      final ilacAdi = kayit['ilac'] != null ? kayit['ilac']['ilac_adi'] : 'Bilinmeyen İlaç';

      final bugun = DateTime.now();
      final gecenGun = bugun.difference(uygulamaTarihi).inDays;
      final kalanGun = beklemeSuresi - gecenGun;

      // 4. Karar Mekanizması (Decision Tree)
      if (gecenGun >= beklemeSuresi) {
        setState(() {
          _hasatGuvenliMi = true;
          _uyariMesaji = "Son atılan '$ilacAdi' ilacının etkisi geçmiş. Hasat GÜVENLİ! ✅";
        });
      } else {
        setState(() {
          _hasatGuvenliMi = false;
          _uyariMesaji = "TEHLİKE! 🛑\n'$ilacAdi' ilacının bekleme süresi dolmadı.\nGüvenli hasat için $kalanGun gün daha beklemelisiniz!";
        });
      }
    } catch (e) {
      setState(() {
        _uyariMesaji = "Hesaplama hatası: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hasatiKaydet() async {
    if (_miktarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Miktar girmelisin patron!')));
      return;
    }
    
    try {
      await _supabase.from('hasatlar').insert({
        'alan_id': widget.alanId,
        'kullanici_id': _supabase.auth.currentUser!.id,
        'miktar_kg': double.parse(_miktarController.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasat başarıyla kaydedildi!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kaydedilemedi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.alanAdi} - Hasat')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: _hasatGuvenliMi ? Colors.green.shade100 : Colors.red.shade100,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            _hasatGuvenliMi ? Icons.check_circle : Icons.warning_amber_rounded,
                            color: _hasatGuvenliMi ? Colors.green : Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _uyariMesaji,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _hasatGuvenliMi ? Colors.green.shade900 : Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_hasatGuvenliMi) ...[
                    TextField(
                      controller: _miktarController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hasat Edilen Miktar (Kg/Ton)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _hasatiKaydet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Hasatı Sisteme İşle', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
