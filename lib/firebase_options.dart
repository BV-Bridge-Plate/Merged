// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDNmmeJnMCV_Uhc30HvYsNhe3cYX89KwfE',
    appId: '1:357897977629:web:c51aa61a1bfdb5090a6bf4',
    messagingSenderId: '357897977629',
    projectId: 'bridgeplate-7b7b5',
    authDomain: 'bridgeplate-7b7b5.firebaseapp.com',
    storageBucket: 'bridgeplate-7b7b5.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNFmozdt1tvdA_ZIYbVV83BDR59qnwsH8',
    appId: '1:357897977629:android:4b8837711ed083e60a6bf4',
    messagingSenderId: '357897977629',
    projectId: 'bridgeplate-7b7b5',
    storageBucket: 'bridgeplate-7b7b5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzZ7G3aMGCbFcJhejJlFlzGFTp35iBQ-A',
    appId: '1:357897977629:ios:ce9cf5a0039b86dc0a6bf4',
    messagingSenderId: '357897977629',
    projectId: 'bridgeplate-7b7b5',
    storageBucket: 'bridgeplate-7b7b5.appspot.com',
    iosBundleId: 'com.example.ipfs',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDzZ7G3aMGCbFcJhejJlFlzGFTp35iBQ-A',
    appId: '1:357897977629:ios:182348d2cac88eb90a6bf4',
    messagingSenderId: '357897977629',
    projectId: 'bridgeplate-7b7b5',
    storageBucket: 'bridgeplate-7b7b5.appspot.com',
    iosBundleId: 'com.example.ipfs.RunnerTests',
  );
}
