import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> kayitOl({
    required String email,
    required String password,
    required String adSoyad,
    required String telefon,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = response.user;

      if (user != null) {
        final rolResponse = await _supabase
            .from('roller')
            .select('id')
            .eq('rol_adi', 'isci')
            .single();
            
        final String isciRolId = rolResponse['id'];

        await _supabase.from('kullanicilar').insert({
          'id': user.id, 
          'ad_soyad': adSoyad,
          'telefon': telefon,
          'rol_id': isciRolId,
        });
      }
      
      return response;
    } catch (e) {
      throw Exception('Kayıt hatası patron: $e');
    }
  }

  Future<AuthResponse> girisYap({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Giriş hatası: $e');
    }
  }

  Future<void> cikisYap() async {
    await _supabase.auth.signOut();
  }
  
  User? get mevcutKullanici => _supabase.auth.currentUser;
}