import '../security/security_constants.dart';

class InputValidator {
  static String? email(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'Email is required.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < SecurityConstants.minimumPasswordLength) {
      return 'Password must contain at least '
          '${SecurityConstants.minimumPasswordLength} characters.';
    }

    return null;
  }

  static String? requiredText(String value, {String fieldName = 'This field'}) {
    if (value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    if (value.trim().length > SecurityConstants.maxTextInputLength) {
      return '$fieldName is too long.';
    }

    return null;
  }
}
