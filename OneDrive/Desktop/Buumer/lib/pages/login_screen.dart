import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 1. Sayfa artık "StatefulWidget" çünkü metin kutularının (TextField)
//    içeriğini hafızada tutmamız gerekiyor.
class LoginScreen extends StatefulWidget {
  // 2. 'onLogin' parametresini ve 'required' hatasını kaldırdık.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 3. E-posta ve şifre kutularını kontrol etmek için 'controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 4. Firebase Authentication servisini çağırıyoruz
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 5. Controller'ları hafızadan silmek için dispose
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FONKSİYONLAR ---

  // 6. E-posta ve Şifre ile GİRİŞ YAP
  Future<void> _signInWithEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Not: 'main.dart' içindeki StreamBuilder sayesinde
      // giriş başarılı olduğunda otomatik olarak HomePage'e yönlenecek.
    } on FirebaseAuthException catch (e) {
      // Hata olursa kullanıcıya göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Giriş hatası')),
        );
      }
    }
  }

  // 7. E-posta ve Şifre ile KAYIT OL
  Future<void> _signUpWithEmail() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Kayıt başarılı olduğunda da otomatik olarak HomePage'e yönlenecek.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Kayıt hatası')),
        );
      }
    }
  }

  // 8. GOOGLE ile GİRİŞ YAP
  Future<void> _signInWithGoogle() async {
    try {
      // Google giriş pop-up'ını tetikle
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Kullanıcı pop-up'ı kapattı
        return;
      }
      
      // Google'dan kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase'e Google bilgileriyle giriş yap
      await _auth.signInWithCredential(credential);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google ile giriş hatası: $e')),
        );
      }
    }
  }

  // --- ARAYÜZ ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 9. 'backgroundColor' uyarısı düzeltildi.
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Buumer\'a Giriş Yap'),
      ),
      body: Center(
        // Ekran taşmasını engellemek için kaydırılabilir yaptık
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_person,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hoş Geldiniz',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 10. E-posta metin kutusu (TODO çözüldü)
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 11. Şifre metin kutusu (TODO çözüldü)
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Şifreyi gizler
                ),
                const SizedBox(height: 32),

                // 12. GİRİŞ YAP butonu
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Tam genişlik
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _signInWithEmail, // Giriş fonksiyonunu çağır
                  child: const Text('Giriş Yap', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 12),

                // 13. GOOGLE ile GİRİŞ YAP butonu
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  icon: Image.asset('assets/google_logo.png', height: 24), // Google logosu (bunu eklemen lazım)
                  // Eğer logo yoksa: icon: Icon(Icons.g_mobiledata, size: 30),
                  label: const Text('Google ile Giriş Yap', style: TextStyle(fontSize: 16)),
                  onPressed: _signInWithGoogle, // Google giriş fonksiyonunu çağır
                ),
                
                const SizedBox(height: 24),
                
                // 14. KAYIT OL butonu
                TextButton(
                  onPressed: _signUpWithEmail, // Kayıt fonksiyonunu çağır
                  child: Text(
                    'Hesabın yok mu? Kayıt Ol',
                    style: TextStyle(color: Colors.tealAccent[400]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}