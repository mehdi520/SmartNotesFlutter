class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    // This regex allows for international phone numbers
    // It accepts formats like: +1234567890, 1234567890, (123) 456-7890
    final phoneRegex = RegExp(
      r'^(\+\d{1,3}[- ]?)?\d{10}$',
    );
    return phoneRegex.hasMatch(phone);
  }

  static bool hasUpperCase(String value) {
    return value.contains(RegExp(r'[A-Z]'));
  }

  static bool hasLowerCase(String value) {
    return value.contains(RegExp(r'[a-z]'));
  }

  static bool hasNumber(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }

  static bool hasSpecialChar(String value) {
    return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
} 