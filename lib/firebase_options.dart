
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyDvJ1F3xq1PQlSph-FitaTQpAt5_zNjUsM",
        authDomain: "maintainmate4u.firebaseapp.com",
        projectId: "maintainmate4u",
        storageBucket: "maintainmate4u.firebasestorage.app",
        messagingSenderId: "579802297892",
        appId: "1:579802297892:web:5675b8a81d4e4dc736cab1",
        measurementId: "G-T9H0E7N3XM",
      );
    }
    // Return dummy options to prevent compile error. 
    // User MUST replace this with real config.
    return const FirebaseOptions(
      apiKey: 'AIzaSyDvJ1F3xq1PQlSph-FitaTQpAt5_zNjUsM',
      appId: '1:579802297892:web:5675b8a81d4e4dc736cab1',
      messagingSenderId: '579802297892',
      projectId: 'maintainmate4u',
      authDomain: 'maintainmate4u.firebaseapp.com',
      storageBucket: 'maintainmate4u.firebasestorage.app',
      measurementId: 'G-T9H0E7N3XM',
    );
    
  }
}
