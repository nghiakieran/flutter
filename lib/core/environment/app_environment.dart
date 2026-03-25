enum AppEnvironmentName { dev, prod, testing }

class AppEnvironment {
  AppEnvironment._();

  static const String _envKey = 'ENV';

  static AppEnvironmentName get current {
    final env = String.fromEnvironment(_envKey, defaultValue: 'dev');
    if (env == 'prod') return AppEnvironmentName.prod;
    if (env == 'testing') return AppEnvironmentName.testing;
    return AppEnvironmentName.dev; // default
  }

  static String get apiBaseUrl {
    if (current == AppEnvironmentName.prod) {
      return 'https://api.example.com';
    }
    if (current == AppEnvironmentName.testing) {
      return 'https://test-api.example.com';
    }
    // Android emulator: http://10.0.2.2:5000
    // iOS simulator/Localhost: http://localhost:5000
    return 'http://localhost:5000';
  }
}
