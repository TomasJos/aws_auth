
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConfirmScreen extends StatefulWidget {
  final String email;

  const ConfirmScreen({super.key, required this.email});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final _codeController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _confirm() async {
    setState(() => _isLoading = true);
    final code = _codeController.text.trim();

    final success = await _authService.confirmSignUp(widget.email, code);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration confirmed! Please login.')),
      );
      // Pop back to the login screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirmation failed. Please check the code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A verification code was sent to \${widget.email}'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _confirm,
                    child: const Text('Confirm'),
                  ),
          ],
        ),
      ),
    );
  }
}
