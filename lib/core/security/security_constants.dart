class SecurityConstants {
  static const int minimumPasswordLength = 8;

  static const Duration sessionTimeout = Duration(minutes: 30);

  static const int maxLoginAttempts = 5;

  static const Duration loginLockoutDuration = Duration(minutes: 5);

  static const int maxImageSizeInBytes = 10 * 1024 * 1024;

  static const int maxTextInputLength = 500;
}
