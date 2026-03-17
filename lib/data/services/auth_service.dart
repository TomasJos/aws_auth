import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, dynamic>?> getCurrentUserAndAttributes() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final attributes = await Amplify.Auth.fetchUserAttributes();
        
        String? name;
        for (final attribute in attributes) {
          if (attribute.userAttributeKey == AuthUserAttributeKey.name) {
            name = attribute.value;
          }
        }
        
        return {
          'user': user,
          'name': name,
        };
      }
      return null;
    } on AuthException catch (e) {
      safePrint('AuthSession error: \${e.message}');
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    if (result.isSignedIn) {
      await _storageService.writeToken('user_email', email);
    }
    return result.isSignedIn;
  }

  Future<bool> signUp(String email, String password, String name) async {
    final userAttributes = {
      AuthUserAttributeKey.email: email,
      AuthUserAttributeKey.name: name,
    };
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: SignUpOptions(userAttributes: userAttributes),
    );
    return result.isSignUpComplete ||
        result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp;
  }

  Future<bool> confirmSignUp(String email, String confirmationCode) async {
    final result = await Amplify.Auth.confirmSignUp(
      username: email,
      confirmationCode: confirmationCode,
    );
    return result.isSignUpComplete;
  }

  Future<void> resendSignUpCode(String email) async {
    await Amplify.Auth.resendSignUpCode(username: email);
  }

  Future<void> resetPassword(String email) async {
    await Amplify.Auth.resetPassword(username: email);
  }

  Future<bool> confirmResetPassword(
      String email, String newPassword, String confirmationCode) async {
    await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode);
    return true;
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
    await _storageService.clearAll();
  }
}
