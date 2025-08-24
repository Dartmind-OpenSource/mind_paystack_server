class RequestValidators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    
    return null;
  }

  static String? validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }
    
    final amountValue = int.tryParse(amount);
    if (amountValue == null) {
      return 'Amount must be a valid number';
    }
    
    if (amountValue <= 0) {
      return 'Amount must be greater than zero';
    }
    
    return null;
  }

  static String? validateReference(String? reference) {
    if (reference == null || reference.isEmpty) {
      return 'Reference is required';
    }
    
    if (reference.length < 3) {
      return 'Reference must be at least 3 characters long';
    }
    
    return null;
  }

  static String? validatePin(String? pin) {
    if (pin == null || pin.isEmpty) {
      return 'PIN is required';
    }
    
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN must be exactly 4 digits';
    }
    
    return null;
  }

  static String? validateOtp(String? otp) {
    if (otp == null || otp.isEmpty) {
      return 'OTP is required';
    }
    
    if (!RegExp(r'^\d{4,8}$').hasMatch(otp)) {
      return 'OTP must be 4-8 digits';
    }
    
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      return 'Phone number must be in international format (+1234567890)';
    }
    
    return null;
  }

  static String? validateBirthday(String? birthday) {
    if (birthday == null || birthday.isEmpty) {
      return 'Birthday is required';
    }
    
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthday)) {
      return 'Birthday must be in YYYY-MM-DD format';
    }
    
    try {
      final date = DateTime.parse(birthday);
      final now = DateTime.now();
      final age = now.year - date.year;
      
      if (date.isAfter(now)) {
        return 'Birthday cannot be in the future';
      }
      
      if (age > 150) {
        return 'Invalid birth date';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    
    return null;
  }

  static Map<String, String> validateCardData(Map<String, dynamic>? cardData) {
    final errors = <String, String>{};
    
    if (cardData == null) {
      errors['card'] = 'Card data is required';
      return errors;
    }
    
    final number = cardData['number'] as String?;
    if (number == null || number.isEmpty) {
      errors['card.number'] = 'Card number is required';
    } else if (number.length < 13 || number.length > 19) {
      errors['card.number'] = 'Invalid card number length';
    }
    
    final cvv = cardData['cvv'] as String?;
    if (cvv == null || cvv.isEmpty) {
      errors['card.cvv'] = 'CVV is required';
    } else if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) {
      errors['card.cvv'] = 'CVV must be 3 or 4 digits';
    }
    
    final expiryMonth = cardData['expiry_month'] as String?;
    if (expiryMonth == null || expiryMonth.isEmpty) {
      errors['card.expiry_month'] = 'Expiry month is required';
    } else if (!RegExp(r'^(0[1-9]|1[0-2])$').hasMatch(expiryMonth)) {
      errors['card.expiry_month'] = 'Invalid expiry month format (01-12)';
    }
    
    final expiryYear = cardData['expiry_year'] as String?;
    if (expiryYear == null || expiryYear.isEmpty) {
      errors['card.expiry_year'] = 'Expiry year is required';
    } else if (!RegExp(r'^\d{4}$').hasMatch(expiryYear)) {
      errors['card.expiry_year'] = 'Invalid expiry year format (YYYY)';
    }
    
    return errors;
  }

  static String? validateAuthorizationCode(String? authCode) {
    if (authCode == null || authCode.isEmpty) {
      return 'Authorization code is required';
    }
    
    if (authCode.length < 10) {
      return 'Invalid authorization code';
    }
    
    return null;
  }

  static String? validateTransactionId(String? id) {
    if (id == null || id.isEmpty) {
      return 'Transaction ID is required';
    }
    
    final idValue = int.tryParse(id);
    if (idValue == null || idValue <= 0) {
      return 'Invalid transaction ID';
    }
    
    return null;
  }

  static Map<String, String> validateRequiredFields(
    Map<String, dynamic> data,
    List<String> requiredFields,
  ) {
    final errors = <String, String>{};
    
    for (final field in requiredFields) {
      final value = data[field];
      if (value == null || 
          (value is String && value.isEmpty) ||
          (value is List && value.isEmpty) ||
          (value is Map && value.isEmpty)) {
        errors[field] = '$field is required';
      }
    }
    
    return errors;
  }
}