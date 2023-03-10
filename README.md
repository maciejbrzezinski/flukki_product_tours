![Flutter logo](https://user-images.githubusercontent.com/34410554/218568476-2f68aaef-992d-4c3e-965e-4ac34c282a53.png)
**First no-code product tour builder for Flutter**
https://www.flukki.com/

## Flukki SDK + product tours builder
One day I was thinking, what cool Flutter project I can create. And here we are today :)

### User perspective
![display](https://user-images.githubusercontent.com/34410554/218572065-34773949-35e5-44cb-ab73-d88118c6862d.gif)

### Builder
![creation](https://user-images.githubusercontent.com/34410554/218572058-3e4ee485-270a-401a-998e-aaebb4263c5f.gif)

![user example](https://user-images.githubusercontent.com/34410554/218571902-0027189b-01a8-489c-8b79-e4b6e07a05af.gif)


### Limitations
This is the very beginning of our story, and please be aware, that you will possibly experience:
- Plugin is fragile for widget tree changes. For example you will wrap your pointed widget with Center, or some other widget and plugin will stop to recognize the original widget.
- On web you should use CanvasKit renderer instead of the HTML one, because overlays were not working properly there
- Product tours created in debug mode won't work in release mode and the other way around

### Advantages
After creating an account at https://www.flukki.com/ you will be able to get your **key** (it will be needed during configuration).
Flukki will help you in:
- building product tours without coding, inside of your app. You will achieve thd best UX by building a product tour on web
- measure stats, like skip rate or success rate
- delivering new and updated product tours to your users without app store deploy
- product tours are triggered by the proper widget appear on the screen

### Configuration
1. Add Flukki to you project
```yaml 
dependencies:
  flukki_product_tours: ^1.1.1
```
2. Add environment variable to your Flutter run method
```bash
--dart-define=flutter.memory_allocations=true
```
After change you should have something like 
```bash
flutter run --release --dart-define=flutter.memory_allocations=true
```
3. Initialize the plugin
```dart
Flukki.instance.initialize(appName: 'Awesome app', key: key)
```
4. Wrap your app with our widget
```dart
return MaterialApp(
      home: FlukkiProductTour(
        child: Scaffold(
```
5. Turn on the builder
```dart
Flukki.instance.turnOnBuilder()
```
That's all, now publish your app, create a product tour and we will take care about everything else
