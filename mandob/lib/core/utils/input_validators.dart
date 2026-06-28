class InputValidators {
  static String? required(String? value, {String message = 'هذا الحقل مطلوب'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? number(String? value, {String message = 'يجب إدخال رقم صحيح'}) {
    if (value == null || value.trim().isEmpty) return null; // Use required() if mandatory
    if (double.tryParse(value) == null) {
      return message;
    }
    return null;
  }

  static String? positiveNumber(String? value, {String message = 'يجب إدخال رقم أكبر من صفر'}) {
    final numError = number(value);
    if (numError != null) return numError;
    
    if (value != null && value.trim().isNotEmpty) {
      final val = double.parse(value);
      if (val <= 0) {
        return message;
      }
    }
    return null;
  }
}
