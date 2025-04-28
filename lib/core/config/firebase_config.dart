import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sport_equipment_rent/firebase_options.dart';

class FirebaseConfig {
  static bool _initialized = false;

  /// Initializes Firebase services with platform-specific options
  /// Throws [Exception] if initialization fails
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firebase Storage settings
      _configureStorage();

      _initialized = true;
      print('Firebase initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing Firebase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Configures Firebase Storage settings
  static void _configureStorage() {
    // Set storage settings
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 3));
    FirebaseStorage.instance.setMaxOperationRetryTime(const Duration(seconds: 3));
  }

  /// Returns whether Firebase has been initialized
  static bool get isInitialized => _initialized;
}