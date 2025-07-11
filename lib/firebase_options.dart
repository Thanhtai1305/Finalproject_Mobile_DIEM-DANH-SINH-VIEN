// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7vCwzw9VJICraqjXodAB2F4F71euqbak',
    appId: '1:97791582149:web:c6be9d5eb8d731982335ac',
    messagingSenderId: '97791582149',
    projectId: 'attendancesystem-b8723',
    authDomain: 'attendancesystem-b8723.firebaseapp.com',
    databaseURL: 'https://attendancesystem-b8723-default-rtdb.firebaseio.com',
    storageBucket: 'attendancesystem-b8723.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2-6KHzTgSrxcGuBUmUsA5Q8W1IyRAYBU',
    appId: '1:97791582149:android:0dc2966c8b3735242335ac',
    messagingSenderId: '97791582149',
    projectId: 'attendancesystem-b8723',
    databaseURL: 'https://attendancesystem-b8723-default-rtdb.firebaseio.com',
    storageBucket: 'attendancesystem-b8723.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7H1FAA3f0PGHdMZRxTgOy3HKv30b--Zs',
    appId: '1:97791582149:ios:c88d555dc34c320d2335ac',
    messagingSenderId: '97791582149',
    projectId: 'attendancesystem-b8723',
    databaseURL: 'https://attendancesystem-b8723-default-rtdb.firebaseio.com',
    storageBucket: 'attendancesystem-b8723.firebasestorage.app',
    iosBundleId: 'com.example.rollCall',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7H1FAA3f0PGHdMZRxTgOy3HKv30b--Zs',
    appId: '1:97791582149:ios:c88d555dc34c320d2335ac',
    messagingSenderId: '97791582149',
    projectId: 'attendancesystem-b8723',
    databaseURL: 'https://attendancesystem-b8723-default-rtdb.firebaseio.com',
    storageBucket: 'attendancesystem-b8723.firebasestorage.app',
    iosBundleId: 'com.example.rollCall',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7vCwzw9VJICraqjXodAB2F4F71euqbak',
    appId: '1:97791582149:web:7a8bbe92c270af6f2335ac',
    messagingSenderId: '97791582149',
    projectId: 'attendancesystem-b8723',
    authDomain: 'attendancesystem-b8723.firebaseapp.com',
    databaseURL: 'https://attendancesystem-b8723-default-rtdb.firebaseio.com',
    storageBucket: 'attendancesystem-b8723.firebasestorage.app',
  );
}
