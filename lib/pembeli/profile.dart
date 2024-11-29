import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_shop/pembeli/creator.dart';
import 'package:online_shop/pembeli/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedTimeZone = 'WIB'; // Default timezone for WIB
  String currentTime = 'Loading...';
  Timer? timer;

  // Map untuk menyimpan offset zona waktu
  final Map<String, int> timeZoneOffsets = {
    'WIB': 7, // UTC+7
    'WITA': 8, // UTC+8
    'WIT': 9, // UTC+9
    'London': 0, // UTC±0
  };

  @override
  void initState() {
    super.initState();
    getTime();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  void getTime() {
    // Mendapatkan waktu sekarang
    DateTime now = DateTime.now();

    // Menghitung offset berdasarkan zona waktu yang dipilih
    int offset = timeZoneOffsets[selectedTimeZone]!;
    DateTime localTime =
        now.add(Duration(hours: offset - 7)); // WIB sebagai referensi

    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(localTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan waktu
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentTime,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8), // Jarak antara waktu dan dropdown
                DropdownButton<String>(
                  value: selectedTimeZone,
                  items: <String>[
                    'WIB', // UTC+7
                    'WITA', // UTC+8
                    'WIT', // UTC+9
                    'London' // UTC±0
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTimeZone = newValue!;
                      getTime(); // Update time when timezone changes
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32), // Jarak antara jam dan tombol

            // Tombol Creator
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Warna latar belakang
                foregroundColor: Colors.white, // Warna teks
                minimumSize: const Size(double.infinity, 60), // Ukuran tombol
              ),
              onPressed: () {
                // Navigasi ke halaman CreatorScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatorScreen()),
                );
              },
              child: const Text("Creator"),
            ),
            const SizedBox(height: 16),

            // Tombol Your Order (Sekarang navigasi ke HistoryScreen)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              child: const Text("Your Order"),
            ),
            const SizedBox(height: 16),

            // Tombol Logout
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
