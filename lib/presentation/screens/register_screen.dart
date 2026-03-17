import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();
      final success = await context.read<AuthProvider>().signUp(
            email,
            _passwordController.text.trim(),
            name,
          );
      
      if (mounted) {
        if (success) {
          context.push('/otp', extra: email);
        } else {
          final error = context.read<AuthProvider>().errorMessage;
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    final isLoading = status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Full name',
                    controller: _nameController,
                    validator: (v) => Validators.requiredField(v, 'Name'),
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Email',
                    hint: 'name@example.com',
                    controller: _emailController,
                    validator: Validators.emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a strong password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: Validators.passwordValidator,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Repeat your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: (v) => Validators.confirmPasswordValidator(v, _passwordController.text),
                    prefixIcon: Icons.lock_reset,
                  ),
                  const SizedBox(height: 48),
                  PrimaryButton(
                    text: 'Register',
                    onPressed: _handleRegister,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

