// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-5fT_b99xiJvrfI_l59AEtyjuhK8guCQ',
    appId: '1:183486592835:web:afcacaef1b705b81e6e1f6',
    messagingSenderId: '183486592835',
    projectId: 'whatsappweb-45bc9',
    authDomain: 'whatsappweb-45bc9.firebaseapp.com',
    storageBucket: 'whatsappweb-45bc9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjg25QhqYgP-vI-LW-LSZjEYA892h_fM0',
    appId: '1:183486592835:android:a062f2ece642f832e6e1f6',
    messagingSenderId: '183486592835',
    projectId: 'whatsappweb-45bc9',
    storageBucket: 'whatsappweb-45bc9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTKviHuBzMRakDmq8oz6HsSlxtLngEZrQ',
    appId: '1:183486592835:ios:40644f4e63fb3bace6e1f6',
    messagingSenderId: '183486592835',
    projectId: 'whatsappweb-45bc9',
    storageBucket: 'whatsappweb-45bc9.appspot.com',
    iosClientId: '183486592835-7bkv8qp816neshhnblph4afi0md8r0iv.apps.googleusercontent.com',
    iosBundleId: 'com.banach.jonny',
  );
}
