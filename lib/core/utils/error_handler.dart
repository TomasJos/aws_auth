import 'package:amplify_flutter/amplify_flutter.dart';

class ErrorHandler {
  static String handleAuthException(Exception e) {
    if (e is AuthException) {
      final message = e.message;
      if (message.contains('UserNotFoundException')) {
        return 'No account found with this email.';
      } else if (message.contains('NotAuthorizedException') || message.contains('Incorrect username or password.')) {
        return 'Incorrect email or password.';
      } else if (message.contains('UsernameExistsException') || message.contains('User already exists')) {
        return 'An account with this email already exists.';
      } else if (message.contains('CodeMismatchException') || message.contains('Invalid verification code')) {
        return 'Invalid verification code provided, please try again.';
      } else if (message.contains('ExpiredCodeException')) {
        return 'The verification code has expired. Please request a new one.';
      } else if (message.contains('LimitExceededException')) {
        return 'Attempt limit exceeded, please try after some time.';
      } else if (message.toLowerCase().contains('network') || message.toLowerCase().contains('unknown') || message.toLowerCase().contains('connection')) {
        return 'Network error. Please check your connection. (If testing locally, ensure amplifyconfiguration.dart has your real AWS Pool IDs)';
      } else if (message.toLowerCase().contains('did not conform to the schema: name') || message.toLowerCase().contains('name') && message.toLowerCase().contains('required')) {
         return 'A valid Full Name is required by the server configuration.';
      }
      return message;
    }
    
    final strMsg = e.toString();
    if (strMsg.contains('No internet connection')) {
      return 'No internet connection. Please turn on Wi-Fi or Cellular data.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}
