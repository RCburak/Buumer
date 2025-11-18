import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Firestore'u import et

// 1. STATEFUL WIDGET'A DÖNÜŞTÜ
class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 2. Firebase servislerini ve TextField controller'larını tanımla
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  bool _isLoading = true; // Yükleniyor durumu

  // 3. Sayfa ilk açıldığında veritabanından mevcut veriyi çek
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      // 'users' koleksiyonundan, o anki kullanıcının ID'sine sahip dökümanı al
      final DocumentSnapshot doc = await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (doc.exists) {
        // Döküman varsa, veriyi al ve TextField'lara yaz
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _ageController.text = data['age'] != null ? data['age'].toString() : '';
        });
      }
    } catch (e) {
      // Hata yönetimi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil yüklenemedi: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Yükleme bitti
      });
    }
  }

  // 4. "Kaydet" butonuna basıldığında veriyi Firestore'a yaz
  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    
    // Yükleniyor animasyonunu başlat
    setState(() {
      _isLoading = true;
    });

    try {
      // 'users' koleksiyonuna, kullanıcının ID'si ile yeni bir döküman (veya güncelleme) yap
      await _firestore.collection('users').doc(_currentUser!.uid).set({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0, // Yaşı sayı olarak kaydet
        'email': _currentUser!.email, // Email'i de kaydedelim
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla kaydedildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: Profil kaydedilemedi. $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Yükleme bitti
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // 5. ARAYÜZ (build metodu)
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading 
          ? const CircularProgressIndicator() // Yükleniyorsa animasyon göster
          : SingleChildScrollView( // Klavye açılınca taşmayı önler
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profil Simgesi
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _nameController.text.isNotEmpty 
                          ? _nameController.text[0].toUpperCase() // İsim varsa baş harfi
                          : _currentUser?.email?[0].toUpperCase() ?? 'B', // Yoksa email baş harfi
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // E-posta (Değiştirilemez)
                  Text(
                    _currentUser?.email ?? 'E-posta bulunamadı', 
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // "İsim" TextField
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'İsim',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // "Yaş" TextField
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Yaş',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // Sadece sayı klavyesi
                  ),
                  const SizedBox(height: 32),

                  // "Kaydet" Butonu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _saveProfile,
                    child: const Text('Profili Kaydet', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),

                  // "Çıkış Yap" Butonu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: widget.onLogout, // Çıkış fonksiyonu (main.dart'tan geliyor)
                    child: const Text('Çıkış Yap', style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
    );
  }
}