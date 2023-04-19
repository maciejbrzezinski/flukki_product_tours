import 'dart:async';

import 'package:flukki_product_tours/flukki_product_tours.dart';
import 'package:flutter/material.dart';

Future<void> printAsync() async {
await Future.delayed(const Duration(milliseconds: 0))
    .then((value) => print('Hello world async'));
}

Future m2(Future f) async {
  await f;
}

Future m1(Future f) async {
  await m2(f);
}

Future<void> main() async {
  final future = m1(printAsync());
  print('First');
  await future;
  print('Second');
  print('Third');

  WidgetsFlutterBinding.ensureInitialized();

  await Flukki.instance.initialize(appName: 'Awesome app', key: 'xyz');
  await Flukki.instance.signInAnonymous();

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
