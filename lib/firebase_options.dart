// Replace the placeholder values below with your Firebase project values.
// Use the FlutterFire CLI or Firebase console to generate the correct configuration.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHKd0Wk0UXc_PQgkPiGxdMj_54EV2zy3Q',
    appId: '1:576905925053:android:0dd879984fbf1b01bec2d4',
    messagingSenderId: '576905925053',
    projectId: 'eletiva-p2-5321a',
    storageBucket: 'eletiva-p2-5321a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_o4s6eUxKFITYQ582Hy7gB7v4BluyF4U',
    appId: '1:576905925053:ios:7966df564ab0510dbec2d4',
    messagingSenderId: '576905925053',
    projectId: 'eletiva-p2-5321a',
    storageBucket: 'eletiva-p2-5321a.firebasestorage.app',
    iosBundleId: 'com.example.powerhouse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAe6CA_mY4elCq0fdtGkqQiFp1C7CAYwPI',
    appId: '1:804984178531:ios:05e332e59b3703a146f556',
    messagingSenderId: '804984178531',
    projectId: 'powerhouse-flutter',
    storageBucket: 'powerhouse-flutter.firebasestorage.app',
    iosBundleId: 'com.example.powerhouse',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZk4qpauQ2YRz8o9UlIBC_cXf4jSZUdKw',
    appId: '1:576905925053:web:dba80f119372e15cbec2d4',
    messagingSenderId: '576905925053',
    projectId: 'eletiva-p2-5321a',
    authDomain: 'eletiva-p2-5321a.firebaseapp.com',
    storageBucket: 'eletiva-p2-5321a.firebasestorage.app',
    measurementId: 'G-6Q69SCZBC8',
  );

}