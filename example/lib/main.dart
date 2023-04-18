import 'package:flukki_product_tours/flukki_product_tours.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flukki_product_tours/src/helpers/app_version_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flukki.instance
      .initialize(appName: 'Awesome app', key: 'TYytgMUKYzaxc4DdVZVFpMeWy6e2');
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
            child: Row(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Center(
                                child: Column(
                                  children: [
                                    Center(
                                      child: ElevatedButton(
                                        child: const Text('Open builder'),
                                        onPressed: () =>
                                            Flukki.instance.turnOnBuilder(),
                                      ),
                                    ),
                                    Center(
                                      child: ElevatedButton(
                                        child: const Text('Close builder'),
                                        onPressed: () =>
                                            Flukki.instance.turnOnBuilder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
