import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../hive/location.dart';
import 'location_form.dart';

class AdminLocationScreen extends StatelessWidget {
  // Fungsi untuk menghapus lokasi
  Future<void> _deleteLocation(BuildContext context, Box<Location> box, int index) async {
    // Tampilkan dialog konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus lokasi ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Jika user mengkonfirmasi, hapus lokasi
    if (confirm == true) {
      await box.deleteAt(index);
      
      // Tampilkan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi berhasil dihapus'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Lokasi Obral'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Location>('locations').listenable(),
        builder: (context, Box<Location> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada lokasi tersimpan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final location = box.getAt(index);
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    location!.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () async {
                        final url = Uri.parse(location.mapsUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tidak dapat membuka Google Maps'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Klik selengkapnya di sini',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteLocation(context, box, index),
                    tooltip: 'Hapus Lokasi',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationForm()),
          );
        },
        icon: Icon(Icons.add_location),
        label: Text('Tambah Lokasi'),
      ),
    );
  }
}
