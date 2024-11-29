import 'package:flutter/material.dart';
import 'package:online_shop/api/api_service.dart';
import 'package:online_shop/pembeli/cart_provider.dart';
import 'package:online_shop/hive/hive_provider.dart';
import 'package:online_shop/fitur/login_page.dart';
import 'package:online_shop/fitur/notifikasi_controler.dart'; 
import 'package:online_shop/hive/user.dart';
import 'package:online_shop/pembeli/checkout_provider.dart'; 
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:awesome_notifications/awesome_notifications.dart';
import 'hive/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Hive
  await Hive.initFlutter(); 
  // Register semua Adapter
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(LocationAdapter());  
  // Buka semua box yang diperlukan
  await Hive.openBox<User>('users');
  await Hive.openBox('settings');
  await Hive.openBox<ProductModel>('products'); 
  // Buka box locations dan inisialisasi data default jika kosong
  final locationsBox = await Hive.openBox<Location>('locations');
  if (locationsBox.isEmpty) {
    await locationsBox.add(Location(
      name: "Toko Zola",
      mapsUrl: "https://maps.app.goo.gl/8WBUcFyvvD9Yhs616"
    ));
  }
  // Inisialisasi Awesome Notifications
  await NotificationController.initializeNotification();
  // Tambahkan listener untuk aksi notifikasi
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
  );
  // Jadwalkan notifikasi promo
  await NotificationController.schedulePromoNotifications();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<HiveProvider>(
          create: (_) => HiveProvider(),
        ),
        ChangeNotifierProvider<CheckoutProvider>(
          create: (_) => CheckoutProvider(), 
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class LocationProvider extends ChangeNotifier {
  Box<Location>? _locationBox;
  List<Location> _locations = [];

  LocationProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    _locationBox = Hive.box<Location>('locations');
    _loadLocations();
  }

  void _loadLocations() {
    if (_locationBox != null) {
      _locations = _locationBox!.values.toList();
      notifyListeners();
    }
  }

  List<Location> get locations => _locations;

  Future<void> addLocation(Location location) async {
    await _locationBox?.add(location);
    _loadLocations();
  }

  Future<void> deleteLocation(int index) async {
    await _locationBox?.deleteAt(index);
    _loadLocations();
  }
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return LoginPage();
          } else {
            return LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}