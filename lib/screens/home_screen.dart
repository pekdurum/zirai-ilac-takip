// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zirai_ilac_takip/screens/alan_detay_screen.dart';
import 'package:zirai_ilac_takip/screens/alan_ekle_screen.dart';
import '../core/auth_service.dart';
import 'login_screen.dart';
import 'ilacalama_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  
  String _kullaniciAdi = 'Yükleniyor...';
  String _kullaniciRolu = '';
  List<dynamic> _alanlar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verileriGetir();
  }

  Future<void> _verileriGetir() async {
    try {
      final user = _authService.mevcutKullanici;
      
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
        return; 
      } 

      final kullaniciData = await _supabase
          .from('kullanicilar')
          .select('ad_soyad, roller(rol_adi)')
          .eq('id', user.id)
          .single();

      final alanlarData = await _supabase
          .from('alanlar')
          .select('*, hasatlar(id)') // Tarlanın yanına hasat kayıtlarını da iliştir dedik
          .order('olusturma_tarihi', ascending: false);

      if (mounted) {
        setState(() {
          _kullaniciAdi = kullaniciData['ad_soyad'] ?? 'Bilinmeyen Kullanıcı';
          _kullaniciRolu = kullaniciData['roller']['rol_adi'] ?? 'isci';
          _alanlar = alanlarData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Veri çekme hatası: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cikisYap() async {
    await _authService.cikisYap(); 
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zirai İlaç Takip'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cikisYap,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hoş geldin, $_kullaniciAdi',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rol: ${_kullaniciRolu.toUpperCase()}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: _alanlar.isEmpty
                      ? const Center(child: Text('Henüz kayıtlı bir alan (Tarla/Sera) yok.'))
                      : ListView.builder(
                          itemCount: _alanlar.length,
                          itemBuilder: (context, index) {
                            final alan = _alanlar[index];
                            
                            final hasatlarListesi = alan['hasatlar'] as List<dynamic>? ?? [];
                            final bool hasatEdildiMi = hasatlarListesi.isNotEmpty;

                            return Card(
                              color: hasatEdildiMi ? Colors.grey.shade200 : Colors.white,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Icon(
                                  alan['alan_turu'] == 'Sera' ? Icons.house_siding : Icons.landscape,
                                  // İkon rengini de duruma göre soluklaştırıyoruz
                                  color: hasatEdildiMi ? Colors.grey : Colors.green,
                                ),
                                title: Text(
                                  alan['alan_adi'] ?? 'İsimsiz Alan',
                                  style: TextStyle(
                                    fontWeight: hasatEdildiMi ? FontWeight.normal : FontWeight.bold,
                                    // Hasat edildiyse üstünü çizerek efekti güçlendir (İstersen silebilirsin)
                                    decoration: hasatEdildiMi ? TextDecoration.lineThrough : null,
                                    color: hasatEdildiMi ? Colors.grey.shade700 : Colors.black,
                                  ),
                                ),
                                subtitle: Text('${alan['sehir']} - ${alan['buyukluk_dekar']} Dekar'),
                                trailing: hasatEdildiMi
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.amber.shade700),
                                        ),
                                        child: Text(
                                          'HASAT EDİLDİ',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlanDetayScreen(alan: alan),
                                    ),
                                  ).then((_) {
                                    _verileriGetir(); 
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _kullaniciRolu == 'admin' 
        ? FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlanEkleScreen()),
              ).then((_) => _verileriGetir()); // Tarla eklenip dönünce listeyi tazele
            },
          )
        : null,
    );
  }
}