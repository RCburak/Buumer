import 'package:flutter/material.dart';

// 1. STATESS'TAN STATEFUL'A DÖNÜŞTÜ
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  // 2. VERİTABANI YERİNE SAHTE PROFİL LİSTESİ
  final List<Map<String, String>> _profiles = [
    {
      'name': 'Ayşe',
      'age': '24',
      'city': 'İstanbul',
    },
    {
      'name': 'Zeynep',
      'age': '27',
      'city': 'İzmir',
    },
    {
      'name': 'Mehmet',
      'age': '29',
      'city': 'Ankara',
    },
  ];

  // 3. HANGİ PROFİLDE OLDUĞUMUZU TAKİP EDEN DEĞİŞKEN
  int _currentIndex = 0;

  // 4. BİR SONRAKİ PROFİLİ GÖSTERME FONKSİYONU
  void _showNextProfile() {
    setState(() {
      // Bir sonraki profile geç
      _currentIndex++;
    });
  }

  // Eşleşme kartı oluşturan fonksiyonu güncelledik
  // Artık dışarıdan bir 'profile' verisi alıyor
  Widget _buildMatchCard(BuildContext context, Map<String, String> profile) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(150),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sana Özel Öneri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.person, size: 40, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 5. VERİLERİ LİSTEDEN ALIYORUZ
                      Text(
                        '${profile['name']}, ${profile['age']}', // Örn: Ayşe, 24
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile['city'] ?? '', // Örn: İstanbul
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 6. "GEÇ" BUTONU ARTIK ÇALIŞIYOR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                  onPressed: _showNextProfile, // Sonraki profili göster
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                // 7. "BEĞEN" BUTONU ARTIK ÇALIŞIYOR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                  onPressed: _showNextProfile, // Sonraki profili göster
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 8. LİSTE BİTTİ Mİ DİYE KONTROL EDİYORUZ
    if (_currentIndex >= _profiles.length) {
      // Bütün profiller bittiyse
      return const Center(
        child: Text(
          'Görülecek profil kalmadı.',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    // Liste bitmediyse, o anki profili al
    final currentProfile = _profiles[_currentIndex];

    // Ve o profili 'build' fonksiyonuna gönder
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        // Eşleşme kartı
        _buildMatchCard(context, currentProfile), 
        
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Örnek başka bir kart
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Günün Özeti...'),
          ),
        ),
      ],
    );
  }
}