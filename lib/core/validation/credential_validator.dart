
import '../security/security_constants.dart';

class CredentialValidator {
  static String? validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'Email is required.';
    }

    if (email.length > SecurityConstants.maxTextInputLength) {
      return 'Email is too long.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  // Used for sign-in to preserve compatibility with existing accounts.
  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < SecurityConstants.minimumPasswordLength) {
      return 'Password must contain at least '
          '${SecurityConstants.minimumPasswordLength} characters.';
    }

    if (value.length > SecurityConstants.maxTextInputLength) {
      return 'Password is too long.';
    }

    return null;
  }

  // Used when creating a new account.
  static String? validateRegistrationPassword(String value) {
    final lengthError = validatePassword(value);

    if (lengthError != null) {
      return lengthError;
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter (A–Z).';
    }

    return null;
  }
}
