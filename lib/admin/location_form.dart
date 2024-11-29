import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../hive/location.dart';

class LocationForm extends StatefulWidget {
  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  bool isValidGoogleMapsUrl(String url) {
    // Validasi untuk format URL maps.app.goo.gl
    return url.startsWith('https://maps.app.goo.gl/') || 
           url.startsWith('http://maps.app.goo.gl/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Lokasi Baru'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lokasi',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Cafe Kopi',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan nama lokasi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL Google Maps',
                  border: OutlineInputBorder(),
                  hintText: 'https://maps.app.goo.gl/xxxxx',
                  helperText: 'Masukkan URL dari tombol Share di Google Maps',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan URL Google Maps';
                  }
                  if (!isValidGoogleMapsUrl(value)) {
                    return 'URL harus dalam format https://maps.app.goo.gl/';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final locationsBox = Hive.box<Location>('locations');
                    final location = Location(
                      name: _nameController.text.trim(),
                      mapsUrl: _urlController.text.trim(),
                    );
                    await locationsBox.add(location);
                    
                    // Tampilkan snackbar sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lokasi berhasil disimpan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.save),
                label: Text('Simpan Lokasi'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}