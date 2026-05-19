import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zirai_ilac_takip/screens/hasat_screen.dart';
import 'ilacalama_form_screen.dart'; 

class AlanDetayScreen extends StatefulWidget {
  final Map<String, dynamic> alan; 

  const AlanDetayScreen({super.key, required this.alan});

  @override
  State<AlanDetayScreen> createState() => _AlanDetayScreenState();
}

class _AlanDetayScreenState extends State<AlanDetayScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _gecmisIlaclamalar = [];

  @override
  void initState() {
    super.initState();
    _gecmisiGetir(); 
  }

  Future<void> _gecmisiGetir() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('ilaclamalar')
          .select('*, ilac(ilac_adi)') 
          .eq('alan_id', widget.alan['id'])
          .order('kullanilan_miktar', ascending: false);

      if (mounted) {
        setState(() {
          _gecmisIlaclamalar = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geçmiş yüklenirken hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alan['alan_adi'] ?? 'İsimsiz Tarla'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_basket),
            tooltip: 'Hasat Yap',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HasatEkleScreen(
                    alanId: widget.alan['id'].toString(),
                    alanAdi: widget.alan['alan_adi'],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.agriculture, color: Colors.green, size: 40),
                title: Text('Tür: ${widget.alan['alan_turu']}'),
                subtitle: Text('Şehir: ${widget.alan['sehir']}\nBüyüklük: ${widget.alan['buyukluk_dekar']} Dekar'),
              ),
            ),
            const SizedBox(height: 20),
            
            // Başlık
            const Text(
              'İlaçlama Geçmişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 2),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _gecmisIlaclamalar.isEmpty
                      ? const Center(
                          child: Text(
                            'Henüz bu alana ilaç atılmadı.',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _gecmisIlaclamalar.length,
                          itemBuilder: (context, index) {
                            final kayit = _gecmisIlaclamalar[index];
                            final ilacAdi = kayit['ilac'] != null ? kayit['ilac']['ilac_adi'] : 'Bilinmeyen İlaç';
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.science, color: Colors.white),
                                ),
                                title: Text(ilacAdi),
                                subtitle: Text('Miktar: ${kayit['kullanilan_miktar']} ml/gr'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IlaclamaFormScreen(
                onTanimliAlanId: widget.alan['id'].toString(),
              ),
            ),
          );
          _gecmisiGetir(); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}