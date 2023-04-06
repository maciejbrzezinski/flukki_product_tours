
![Flutter logo](https://user-images.githubusercontent.com/34410554/218568476-2f68aaef-992d-4c3e-965e-4ac34c282a53.png)  
**First no-code product tour builder for Flutter**  
https://www.flukki.com/

## Flukki SDK + product tours builder


### User perspective
![display](https://user-images.githubusercontent.com/34410554/218572065-34773949-35e5-44cb-ab73-d88118c6862d.gif)

### Builder
![creation](https://user-images.githubusercontent.com/34410554/218572058-3e4ee485-270a-401a-998e-aaebb4263c5f.gif)

![user example](https://user-images.githubusercontent.com/34410554/218571902-0027189b-01a8-489c-8b79-e4b6e07a05af.gif)



### Advantages
- building product tours without coding, inside of your app. You will achieve the best UX by building a product tour on web
- measure stats, like skip rate or success rate
- delivering new and updated product tours to your users without app store deploy

### How it works
The whole mechanism is pretty easy.
You configure our plugin and start creating product tours with the builder. The outcome of the builder is sent to our servers and saved there. Thanks to that, we are able to send the product tour to every user of your app. During initialization of the plugin, it fetches the newest product tours and display it to users. You can be sure, that your users always see the most recent version of your onboardings.

### How to get key
1. Create an account at https://www.flukki.com/
2. Click the green button on the left side with 'API KEY' title
3. Done, the key is in your clipboard

### Configuration
1. Add Flukki to you project
```yaml dependencies:  
 flukki_product_tours: ^2.0.0
 ```  
2. Add environment variable to your Flutter run method
   This is crucial part of configuration, because enabling memory allocations allow us analyze widget tree changes in your app. You can check how to configure your IDE and read more about memory allocations here: [Flutter | Understanding the MemoryAllocations](https://medium.com/@maciejbrzezinski/flutter-what-is-memoryallocations-1ee2eb0a8670)
```bash
--dart-define=flutter.memory_allocations=true  
```
3. Initialize the plugin

```dart  
Flukki.instance.initialize(appName: 'Awesome app', key: key)  
```  
4. Sign in
```dart  
await Flukki.instance.signInAnonymous();
or
await Flukki.instance.signInUser(userID);
```  
5. Wrap your app with our widget
```dart  
return MaterialApp(  
 home: FlukkiProductTour( child: Scaffold(  
```  
6. Turn on the builder.
   Please be aware where you use this method! It is intended to be used by a user with super admin role. You can attach it to a button somewhere in a superadmin panel, or create a fancy gesture that will enable the builder, but regular user should not be able to run it. Everyone who is able to run this method can modify product tours.
```dart  
Flukki.instance.turnOnBuilder()  
```  
7. To sign user out just call
```dart  
await Flukki.instance.signOut();  
```  
That's all, now publish your app, create a product tour and we will take care about everything else :)

### Limitations
This is the very beginning of our story, and please be aware, that you will possibly experience:
- Plugin is fragile for widget tree changes. For example you will wrap your pointed widget with Center, or some other widget and plugin will stop to recognize the original widget.
- On web you should use CanvasKit renderer instead of the HTML one, because overlays were not working properly there
- Product tours created in debug mode won't work in release mode and the other way around  
