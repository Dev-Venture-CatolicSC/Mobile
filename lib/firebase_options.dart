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
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para '
          '$defaultTargetPlatform. Use Android ou Web para esta entrega.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions não suporta Fuchsia.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-XN0LSADQUAFzK5cKgQg3zcx_uOhXSno',
    appId: '1:551750097674:web:devventure-web',
    messagingSenderId: '551750097674',
    projectId: 'devventure-441c5',
    storageBucket: 'devventure-441c5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-XN0LSADQUAFzK5cKgQg3zcx_uOhXSno',
    appId: '1:551750097674:android:49ca9ace93024aa29278f3',
    messagingSenderId: '551750097674',
    projectId: 'devventure-441c5',
    storageBucket: 'devventure-441c5.firebasestorage.app',
  );
}
