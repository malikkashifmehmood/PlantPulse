import '../security/security_constants.dart';

class ImageValidator {
  static String? validateSize(int sizeInBytes) {
    if (sizeInBytes <= 0) {
      return 'The selected image is invalid.';
    }

    if (sizeInBytes > SecurityConstants.maxImageSizeInBytes) {
      return 'The selected image is too large.';
    }

    return null;
  }

  static String? validateExtension(String fileName) {
    final normalizedName = fileName.trim().toLowerCase();

    if (normalizedName.isEmpty || !normalizedName.contains('.')) {
      return 'The selected image format is invalid.';
    }

    final extension = normalizedName.split('.').last;

    const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

    if (!allowedExtensions.contains(extension)) {
      return 'This image format is not supported.';
    }

    return null;
  }

  static String? validate({
    required String fileName,
    required int sizeInBytes,
  }) {
    final extensionError = validateExtension(fileName);

    if (extensionError != null) {
      return extensionError;
    }

    return validateSize(sizeInBytes);
  }
}
