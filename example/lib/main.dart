import 'package:flukki_product_tours/flukki_product_tours.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Flukki.instance.initialize(appName: 'Awesome app', key: 'xyz');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlukkiProductTour(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Product tour creator demo'),
          ),
          body: Center(
            child: ElevatedButton(
              child: const Text('Open builder'),
              onPressed: () => Flukki.instance.turnOnBuilder(),
            ),
          ),
        ),
      ),
    );
  }
}
