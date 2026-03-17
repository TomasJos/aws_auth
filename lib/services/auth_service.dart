import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  Future<bool> signIn(String email, String password) async {
    try {
      SignInResult result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      return result.isSignedIn;
    } on AuthException catch (e) {
      safePrint('Error signing in: \${e.message}');
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.email: email,
      };
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      return result.isSignUpComplete ||
          result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp;
    } on AuthException catch (e) {
      safePrint('Error signing up: \${e.message}');
      return false;
    }
  }

  Future<bool> confirmSignUp(String email, String confirmationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      return result.isSignUpComplete;
    } on AuthException catch (e) {
      safePrint('Error confirming sign up: \${e.message}');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      safePrint('Error signing out: \${e.message}');
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } on AuthException catch (e) {
      safePrint('Error getting current user: \${e.message}');
      return null;
    }
  }
}
