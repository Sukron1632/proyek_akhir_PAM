import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checkout_provider.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan instance dari CheckoutProvider untuk mengakses riwayat checkout
    final checkoutProvider = Provider.of<CheckoutProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'), 
        backgroundColor: Colors.black, 
        foregroundColor: Colors.white, 
      ),
      // Menampilkan daftar riwayat checkout dalam bentuk list
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: checkoutProvider.checkoutHistory.length, // Jumlah item dalam riwayat
        itemBuilder: (context, index) {
          final session = checkoutProvider.checkoutHistory[index]; // Mendapatkan data sesi checkout
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), 
            ),
            elevation: 3, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // Menampilkan ID pesanan
                  Text(
                    'Pesanan No: ${session.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8), 
                  Text(
                    'Waktu Checkout: ${session.checkoutTime}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nama Barang:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Menampilkan daftar nama barang yang dipesan
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(), 
                    shrinkWrap: true, 
                    itemCount: session.productNames.length, 
                    itemBuilder: (context, itemIndex) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontSize: 14),
                          ),
                          // Nama produk
                          Expanded(
                            child: Text(
                              session.productNames[itemIndex],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harga Checkout: \$${session.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Menampilkan status pesanan
                  Align(
                    alignment: Alignment.centerRight, 
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: session.status == 'Berhasil Dipesan'
                            ? Colors.green
                            : Colors.yellow[700],
                        borderRadius: BorderRadius.circular(20.0), 
                      ),
                      child: Text(
                        session.status, 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
