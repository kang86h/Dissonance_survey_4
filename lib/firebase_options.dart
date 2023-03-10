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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA_a8RuLp0uZv5ynAOvrgUkRRsIe09GbjQ',
    appId: '1:725989750669:web:17e4baa7babbec800cefc4',
    messagingSenderId: '725989750669',
    projectId: 'dissonance-survey-4',
    authDomain: 'dissonance-survey-4.firebaseapp.com',
    storageBucket: 'dissonance-survey-4.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQIitVWHd7YdkBhgxxvgt-dW9CcLIHbBg',
    appId: '1:725989750669:android:370fb7c9e361f97d0cefc4',
    messagingSenderId: '725989750669',
    projectId: 'dissonance-survey-4',
    storageBucket: 'dissonance-survey-4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBWYz-punqI-QLZOy-YTSIgSg1xO3uHr0',
    appId: '1:725989750669:ios:336c37ae01fd3b5a0cefc4',
    messagingSenderId: '725989750669',
    projectId: 'dissonance-survey-4',
    storageBucket: 'dissonance-survey-4.appspot.com',
    iosClientId: '725989750669-1lvfnjfmam2ml3odovennpvslr0elp15.apps.googleusercontent.com',
    iosBundleId: 'com.example.dissonanceSurvey4',
  );
}
