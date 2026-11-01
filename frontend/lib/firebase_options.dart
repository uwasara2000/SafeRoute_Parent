import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyADXNlLD6sAjltVx7ex7dspX2XcWJYB94s',
    appId: '1:633595353219:android:702e446d78c05ad80ea3b6',
    messagingSenderId: '633595353219',
    projectId: 'track-my-kid-dae5b',
    storageBucket: 'track-my-kid-dae5b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADXNlLD6sAjltVx7ex7dspX2XcWJYB94s',
    appId: '1:633595353219:android:702e446d78c05ad80ea3b6',
    messagingSenderId: '633595353219',
    projectId: 'track-my-kid-dae5b',
    databaseURL: 'https://track-my-kid-dae5b-default-rtdb.firebaseio.com',
    storageBucket: 'track-my-kid-dae5b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADXNlLD6sAjltVx7ex7dspX2XcWJYB94s',
    appId: '1:633595353219:android:702e446d78c05ad80ea3b6',
    messagingSenderId: '633595353219',
    projectId: 'track-my-kid-dae5b',
    storageBucket: 'track-my-kid-dae5b.firebasestorage.app',
  );
}
