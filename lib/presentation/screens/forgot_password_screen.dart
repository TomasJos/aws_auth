import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_emailFormKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().resetPassword(
            _emailController.text.trim(),
          );
      
      if (mounted) {
        if (success) {
          setState(() {
            _codeSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent to email.')),
          );
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

  Future<void> _handleResetPassword() async {
    if (_resetFormKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().confirmResetPassword(
            _emailController.text.trim(),
            _newPasswordController.text.trim(),
            _codeController.text.trim(),
          );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successfully! Please log in.')),
          );
          context.go('/login');
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
            child: !_codeSent ? _buildEmailForm(isLoading) : _buildResetForm(isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 64, color: Color(0xFF3B82F6)),
          const SizedBox(height: 32),
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email to receive a password reset code.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomTextField(
            label: 'Email',
            hint: 'name@example.com',
            controller: _emailController,
            validator: Validators.emailValidator,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Send Code',
            onPressed: _handleSendCode,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm(bool isLoading) {
    return Form(
      key: _resetFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create New Password',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the code sent to ${_emailController.text}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomTextField(
            label: 'Verification Code',
            hint: 'Enter 6-digit code',
            controller: _codeController,
            validator: Validators.otpValidator,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.password,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'New Password',
            hint: 'Create a strong password',
            controller: _newPasswordController,
            isPassword: true,
            validator: Validators.passwordValidator,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Reset Password',
            onPressed: _handleResetPassword,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
