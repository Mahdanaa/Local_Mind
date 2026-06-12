import 'package:flutter/material.dart';

class HomeChatScreen extends StatelessWidget {
  const HomeChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ==============================
          // RUANG KIRI: Sidebar Resepsionis
          // ==============================
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: const Center(child: Text('Nanti Sidebar di sini')),
            ),
          ),

          // Pembatas antar ruangan
          const VerticalDivider(width: 1, thickness: 1),

          // ==============================
          // RUANG KANAN: Meja Makan (Chat Area)
          // ==============================
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Area tempat balon chat muncul
                const Expanded(
                  child: Center(child: Text('Nanti Bubble Chat AI di sini')),
                ),

                // Area input teks di bawah
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tanya sesuatu ke AI lokal...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FloatingActionButton(
                        onPressed: () {}, // Nanti kita isi logika kirim pesan
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
