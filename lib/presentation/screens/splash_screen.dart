import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:amplify_flutter/amplify_flutter.dart' hide AuthProvider;
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' hide AuthProvider;
import '../../amplifyconfiguration.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (!Amplify.isConfigured) {
        final auth = AmplifyAuthCognito();
        await Amplify.addPlugin(auth);
        await Amplify.configure(amplifyconfig);
      }
    } catch (e) {
      debugPrint('Error configuring Amplify: \$e');
    }

    if (mounted) {
      await context.read<AuthProvider>().checkAuthStatus();
      if (mounted) {
        if (context.read<AuthProvider>().status == AuthStatus.authenticated) {
          context.go('/dashboard');
        } else {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'FinSafe Authenticator',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
