import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/home_page.dart';
import 'pages/login_screen.dart';
import 'firebase_options.dart'; // Bu dosyayı flutterfire configure oluşturdu

void main() async {
  // 1. Firebase'in Flutter'a bağlanması için bu kod şart
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- DÜZELTME BURADA ---
  // TODO yorumunu kaldırdık ve Firebase'i başlattık.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // --- DÜZELTME SONU ---

  runApp(const BuumerApp());
}

class BuumerApp extends StatelessWidget {
  const BuumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buumer',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      // 2. YOL AYRIMI (Router)
      // Firebase'in kimlik doğrulama durumunu DİNLE
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Bağlantı bekleniyor...
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Yükleniyor... ekranı
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 3. KARAR
          if (snapshot.hasData) {
            // VERİ VAR = Kullanıcı giriş yapmış demektir
            // HomePage'e çıkış yapma fonksiyonunu gönderiyoruz.
            return HomePage(onLogout: () async {
              await FirebaseAuth.instance.signOut();
            });
          } else {
            // VERİ YOK = Kullanıcı giriş yapmamış
            // LoginScreen'i göster.
            return const LoginScreen();
          }
        },
      ),
    );
  }
}