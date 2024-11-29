import 'package:flutter/material.dart';
import 'package:online_shop/pembeli/checkout_model.dart';

class ManageOrder with ChangeNotifier {
  // Menyimpan daftar riwayat checkout
  final List<CheckoutSession> _checkoutHistory = [
    CheckoutSession(
      id: 1,
      checkoutTime: DateTime.now(),
      productNames: ['Product A', 'Product B'],
      totalPrice: 200.0,
    ),
    CheckoutSession(
      id: 2,
      checkoutTime: DateTime.now().subtract(Duration(days: 1)),
      productNames: ['Product C'],
      totalPrice: 100.0,
    ),
    CheckoutSession(
      id: 3,
      checkoutTime: DateTime.now().subtract(Duration(days: 2)),
      productNames: ['Product D', 'Product E'],
      totalPrice: 300.0,
    ),
  ];

  // Getter untuk mengambil daftar riwayat checkout
  List<CheckoutSession> get checkoutHistory => _checkoutHistory;

  // Mengonfirmasi pesanan berdasarkan ID
  void confirmOrder(int id) {
    final session = _checkoutHistory.firstWhere((s) => s.id == id); // Cari sesi dengan ID yang sesuai
    session.status = 'Pesanan Dikonfirmasi'; // Perbarui status pesanan
    notifyListeners(); // Pemberitahuan ke UI untuk pembaruan
  }
}
