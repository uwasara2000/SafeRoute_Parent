/// Form validation logic for registration fields
class FormValidators {
  /// Validates that the full name is provided and has at least 2 characters
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  /// Validates standard email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates phone number (supports local and international format like +94 7X XXX XXXX)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    // Clean string by removing spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid mobile number (e.g., +94 7X XXX XXXX)';
    }
    return null;
  }

  /// Validates password strength: at least 8 characters, at least 1 digit, and 1 symbol
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#\$&*~_.,<>;:?/\-+=]').hasMatch(value);

    if (!hasNumber || !hasSpecialChar) {
      return 'Password must include at least one number and one symbol';
    }
    return null;
  }

  /// Validates that confirm password matches original password
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

