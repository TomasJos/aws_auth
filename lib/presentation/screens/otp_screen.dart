import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().confirmSignUp(
            widget.email,
            _otpController.text.trim(),
          );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account verified successfully! Please log in.')),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_read, size: 64, color: Color(0xFF10B981)),
                  const SizedBox(height: 32),
                  Text(
                    'Verify Email',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification code to\\n\${widget.email}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Verification Code',
                    hint: 'Enter 6-digit code',
                    controller: _otpController,
                    validator: Validators.otpValidator,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.password,
                  ),
                  const SizedBox(height: 48),
                  PrimaryButton(
                    text: 'Confirm Account',
                    onPressed: _handleConfirm,
                    isLoading: isLoading,
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
