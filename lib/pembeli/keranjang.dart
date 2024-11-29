import 'package:flutter/material.dart';
import 'package:online_shop/pembeli/checkout_provider.dart';
import 'package:online_shop/fitur/notifikasi_controler.dart';
import 'package:online_shop/hive/user.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import '../hive/hive_provider.dart';
import '../hive/product_model.dart';

class KeranjangScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mengambil instance dari CartProvider dan HiveProvider menggunakan Provider
    final cart = Provider.of<CartProvider>(context);
    final hiveProvider = Provider.of<HiveProvider>(context);

    // Menggabungkan item dari CartProvider dan HiveProvider menjadi satu daftar
    final combinedCartItems = [
      ...cart.cartItems.map((product) => {
            'title': product.title, 
            'price': product.price, 
            'image': product.images.isNotEmpty
                ? product.images[0] 
                : 'https://via.placeholder.com/150', 
            'isFromCartProvider': true, 
            'product': product, 
          }),
      ...hiveProvider.cartItems.map((productModel) => {
            'title': productModel.name, 
            'price': productModel.price, 
            'image': productModel.imagePath.isNotEmpty
                ? productModel.imagePath 
                : 'https://via.placeholder.com/150', 
            'isFromCartProvider': false, 
            'product': productModel, 
          }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Pemesanan'), 
        backgroundColor: Colors.black, 
        foregroundColor: Colors.white, 
      ),
      body: combinedCartItems.isEmpty
          ? const Center(child: Text('Keranjang Anda kosong')) 
          : Column(
              children: [
                Expanded(
                  // Menampilkan daftar item dalam keranjang
                  child: ListView.builder(
                    itemCount: combinedCartItems.length, 
                    itemBuilder: (context, index) {
                      final item = combinedCartItems[index]; 
                      final title = item['title'] as String; 
                      final price = item['price'] is int
                          ? (item['price'] as int).toDouble()
                          : item['price'] as double; 
                      final image = item['image'] as String; 
                      final isFromCartProvider =
                          item['isFromCartProvider'] as bool; 
                      final product = item['product']; 

                      return ListTile(
                        leading: Image.network(
                          image, 
                          width: 50,
                          height: 50,
                        ),
                        title: Text(title), 
                        subtitle: Text('Price: \$${price.toStringAsFixed(2)}'), 
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red), // Ikon hapus
                          onPressed: () {
                            if (isFromCartProvider) {
                              // Menghapus dari CartProvider
                              cart.removeFromCart(product as Product);
                            } else {
                              // Menghapus dari HiveProvider
                              hiveProvider.removeFromCart(product as ProductModel);
                            }
                            // Menampilkan snackbar sebagai notifikasi penghapusan
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('$title removed from cart!')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Menampilkan total harga
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${(cart.totalPrice.toDouble() + hiveProvider.totalPrice.toDouble()).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Tombol untuk memproses pesanan
                ElevatedButton(
                  onPressed: () {
                    // Mengambil nama produk untuk checkout
                    final productNames = combinedCartItems
                        .map((item) => item['title'] as String)
                        .toList();
                    // Menghitung total harga
                    final totalPrice = cart.totalPrice.toDouble() +
                        hiveProvider.totalPrice.toDouble();

                    // Menambahkan sesi checkout
                    Provider.of<CheckoutProvider>(context, listen: false)
                        .addCheckoutSession(productNames, totalPrice);

                    // Mengosongkan keranjang
                    cart.clearCart();
                    hiveProvider.clearCart();

                    // Menampilkan notifikasi setelah checkout
                    NotificationController.createNotificationWithDelay();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Warna tombol
                  ),
                  child: const Text(
                    'Pesan',
                    style: TextStyle(color: Colors.white), // Warna teks tombol
                  ),
                )
              ],
            ),
    );
  }
}
